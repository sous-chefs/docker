# This module holds shared logic that doesn't really belong anywhere else in the
# gem.
module Docker::Util
  include Docker::Error

  module_function

  # Attaches to a HTTP stream
  #
  # @param block
  # @param msg_stack [Docker::Messages]
  # @param tty [boolean]
  def attach_for(block, msg_stack, tty = false)
    # If TTY is enabled expect raw data and append to stdout
    if tty
      attach_for_tty(block, msg_stack)
    else
      attach_for_multiplex(block, msg_stack)
    end
  end

  def attach_for_tty(block, msg_stack)
    messages = Docker::Messages.new
    lambda do |c,r,t|
      messages.stdout_messages << c
      messages.all_messages << c
      msg_stack.append(messages)

      block.call c if block
    end
  end

  def attach_for_multiplex(block, msg_stack)
    messages = Docker::Messages.new
    lambda do |c,r,t|
      messages = messages.decipher_messages(c)

      unless block.nil?
        messages.stdout_messages.each do |msg|
          block.call(:stdout, msg)
        end
        messages.stderr_messages.each do |msg|
          block.call(:stderr, msg)
        end
      end

      msg_stack.append(messages)
    end
  end

  def debug(msg)
    Docker.logger.debug(msg) if Docker.logger
  end

  def hijack_for(stdin, block, msg_stack, tty)
    attach_block = attach_for(block, msg_stack, tty)

    lambda do |socket|
      debug "hijack: hijacking the HTTP socket"
      threads = []

      debug "hijack: starting stdin copy thread"
      threads << Thread.start do
        debug "hijack: copying stdin => socket"
        IO.copy_stream stdin, socket

        debug "hijack: closing write end of hijacked socket"
        close_write(socket)
      end

      debug "hijack: starting hijacked socket read thread"
      threads << Thread.start do
        debug "hijack: reading from hijacked socket"

        begin
          while chunk = socket.readpartial(512)
            debug "hijack: got #{chunk.bytesize} bytes from hijacked socket"
            attach_block.call chunk, nil, nil
          end
        rescue EOFError
        end

        debug "hijack: killing stdin copy thread"
        threads.first.kill
      end

      threads.each(&:join)
    end
  end

  def close_write(socket)
    if socket.respond_to?(:close_write)
      socket.close_write
    elsif socket.respond_to?(:io)
      socket.io.close_write
    else
      raise IOError, 'Cannot close socket'
    end
  end

  def parse_json(body)
    JSON.parse(body) unless body.nil? || body.empty? || (body == 'null')
  rescue JSON::ParserError => ex
    raise UnexpectedResponseError, ex.message
  end

  def parse_repo_tag(str)
    if match = str.match(/\A(.*):([^:]*)\z/)
      match.captures
    else
      [str, '']
    end
  end

  def fix_json(body)
    parse_json("[#{body.gsub(/}\s*{/, '},{')}]")
  end

  def create_tar(hash = {})
    output = StringIO.new
    Gem::Package::TarWriter.new(output) do |tar|
      hash.each do |file_name, input|
        tar.add_file(file_name, 0640) { |tar_file| tar_file.write(input) }
      end
    end
    output.tap(&:rewind).string
  end

  def create_dir_tar(directory)
    tempfile = create_temp_file
    directory += '/' unless directory.end_with?('/')

    create_relative_dir_tar(directory, tempfile)

    File.new(tempfile.path, 'r')
  end

  def create_relative_dir_tar(directory, output)
    Gem::Package::TarWriter.new(output) do |tar|
      Find.find(directory) do |prefixed_file_name|
        stat = File.stat(prefixed_file_name)
        next unless stat.file?

        unprefixed_file_name = prefixed_file_name[directory.length..-1]
        add_file_to_tar(
          tar, unprefixed_file_name, stat.mode, stat.size, stat.mtime
        ) do |tar_file|
          IO.copy_stream(File.open(prefixed_file_name, 'rb'), tar_file)
        end
      end
    end
  end

  def add_file_to_tar(tar, name, mode, size, mtime)
    tar.check_closed

    io = tar.instance_variable_get(:@io)

    name, prefix = tar.split_name(name)

    header = Gem::Package::TarHeader.new(:name => name, :mode => mode,
                                         :size => size, :prefix => prefix,
                                         :mtime => mtime).to_s

    io.write header
    os = Gem::Package::TarWriter::BoundedStream.new io, size

    yield os if block_given?

    min_padding = size - os.written
    io.write("\0" * min_padding)

    remainder = (512 - (size % 512)) % 512
    io.write("\0" * remainder)

    tar
  end

  def create_temp_file
    tempfile_name = Dir::Tmpname.create('out') {}
    File.open(tempfile_name, 'wb+')
  end

  def extract_id(body)
    body.lines.reverse_each do |line|
      if (id = line.match(/Successfully built ([a-f0-9]+)/)) && !id[1].empty?
        return id[1]
      end
    end
    raise UnexpectedResponseError, "Couldn't find id: #{body}"
  end

  # Convenience method to get the file hash corresponding to an array of
  # local paths.
  def file_hash_from_paths(local_paths)
    local_paths.each_with_object({}) do |local_path, file_hash|
      unless File.exist?(local_path)
        raise ArgumentError, "#{local_path} does not exist."
      end

      basename = File.basename(local_path)
      if File.directory?(local_path)
        tar = create_dir_tar(local_path)
        file_hash[basename] = tar.read
        tar.close
        FileUtils.rm(tar.path)
      else
        file_hash[basename] = File.read(local_path)
      end
    end
  end

  def build_auth_header(credentials)
    credentials = credentials.to_json if credentials.is_a?(Hash)
    encoded_creds = Base64.encode64(credentials).gsub(/\n/, '')
    {
      'X-Registry-Auth' => encoded_creds
    }
  end

  def build_config_header(credentials)
    if credentials.is_a?(String)
      credentials = JSON.parse(credentials, symbolize_names: true)
    end
    header = {
      "configs" => {
        credentials[:serveraddress].to_s => {
          "username" => credentials[:username].to_s,
          "password" => credentials[:password].to_s,
          "email" => credentials[:email].to_s
        }
      }
    }.to_json

    encoded_header = Base64.encode64(header).gsub(/\n/, '')

    {
      'X-Registry-Config' => encoded_header
    }
  end
end
