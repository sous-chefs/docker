# This class represents a Docker Container. It's important to note that nothing
# is cached so that the information is always up to date.
class Docker::Container
  include Docker::Base

  # Return a List of Hashes that represents the top running processes.
  def top(opts = {})
    resp = Docker::Util.parse_json(connection.get(path_for(:top), opts))
    if resp['Processes'].nil?
      []
    else
      resp['Processes'].map { |ary| Hash[resp['Titles'].zip(ary)] }
    end
  end

  # Wait for the current command to finish executing. Default wait time is
  # `Excon.options[:read_timeout]`.
  def wait(time = nil)
    excon_params = { :read_timeout => time }
    resp = connection.post(path_for(:wait), nil, excon_params)
    Docker::Util.parse_json(resp)
  end

  # Given a command and an optional number of seconds to wait for the currently
  # executing command, creates a new Container to run the specified command. If
  # the command that is currently executing does not return a 0 status code, an
  # UnexpectedResponseError is raised.
  def run(cmd, time = 1000)
    if (code = tap(&:start).wait(time)['StatusCode']).zero?
      commit.run(cmd)
    else
      raise UnexpectedResponseError, "Command returned status code #{code}."
    end
  end

  # Create an Exec instance inside the container
  #
  # @param command [String, Array] The command to run inside the Exec instance
  # @param options [Hash] The options to pass to Docker::Exec
  #
  # @return [Docker::Exec] The Exec instance
  def exec(command, opts = {}, &block)
    # Establish values
    tty = opts.delete(:tty) || false
    detach = opts.delete(:detach) || false
    user = opts.delete(:user)
    stdin = opts.delete(:stdin)
    stdout = opts.delete(:stdout) || !detach
    stderr = opts.delete(:stderr) || !detach

    # Create Exec Instance
    instance = Docker::Exec.create(
      {
        'Container' => self.id,
        'User' => user,
        'AttachStdin' => !!stdin,
        'AttachStdout' => stdout,
        'AttachStderr' => stderr,
        'Tty' => tty,
        'Cmd' => command
      },
      self.connection
    )

    start_opts = {
      :tty => tty,
      :stdin => stdin,
      :detach => detach
    }

    if detach
      instance.start!(start_opts)
      return instance
    else
      instance.start!(start_opts, &block)
    end
  end

  # Export the Container as a tar.
  def export(&block)
    connection.get(path_for(:export), {}, :response_block => block)
    self
  end

  # Attach to a container's standard streams / logs.
  def attach(options = {}, &block)
    stdin = options.delete(:stdin)
    tty   = options.delete(:tty)

    opts = {
      :stream => true, :stdout => true, :stderr => true
    }.merge(options)
    # Creates list to store stdout and stderr messages
    msgs = Docker::Messages.new

    excon_params = {}

    if stdin
      # If attaching to stdin, we must hijack the underlying TCP connection
      # so we can stream stdin to the remote Docker process
      opts[:stdin] = true
      excon_params[:hijack_block] = Docker::Util.hijack_for(stdin, block,
        msgs, tty)
    else
      excon_params[:response_block] = Docker::Util.attach_for(block, msgs, tty)
    end

    connection.post(
      path_for(:attach),
      opts,
      excon_params
    )
    [msgs.stdout_messages, msgs.stderr_messages]
  end

  # Create an Image from a Container's change.s
  def commit(options = {})
    options.merge!('container' => self.id[0..7])
    # [code](https://github.com/dotcloud/docker/blob/v0.6.3/commands.go#L1115)
    # Based on the link, the config passed as run, needs to be passed as the
    # body of the post so capture it, remove from the options, and pass it via
    # the post body
    config = options.delete('run')
    hash = Docker::Util.parse_json(connection.post('/commit',
                                                   options,
                                                   :body => config.to_json))
    Docker::Image.send(:new, self.connection, hash)
  end

  # Return a String representation of the Container.
  def to_s
    "Docker::Container { :id => #{self.id}, :connection => #{self.connection} }"
  end

  # #json returns information about the Container, #changes returns a list of
  # the changes the Container has made to the filesystem.
  [:json, :changes].each do |method|
    define_method(method) do |opts = {}|
      Docker::Util.parse_json(connection.get(path_for(method), opts))
    end
  end

  def logs(opts = {})
    connection.get(path_for(:logs), opts)
  end

  def rename(new_name)
    query = {}
    query['name'] = new_name
    connection.post(path_for(:rename), query)
  end

  def streaming_logs(opts = {}, &block)
    stack_size = opts.delete('stack_size') || -1
    tty = opts.delete('tty') || opts.delete(:tty) || false
    msgs = Docker::MessagesStack.new(stack_size)
    excon_params = {response_block: Docker::Util.attach_for(block, msgs, tty)}

    connection.get(path_for(:logs), opts, excon_params)
    msgs.messages.join
  end

  def start!(opts = {})
    connection.post(path_for(:start), {}, :body => opts.to_json)
    self
  end

  def kill!(opts = {})
    connection.post(path_for(:kill), opts)
    self
  end

  # #start! and #kill! both perform the associated action and
  # return the Container. #start and #kill do the same,
  # but rescue from ServerErrors.
  [:start, :kill].each do |method|
    define_method(method) do |*args|
      begin; public_send(:"#{method}!", *args); rescue ServerError; self end
    end
  end

  # #stop! and #restart! both perform the associated action and
  # return the Container. #stop and #restart do the same,
  # but rescue from ServerErrors.
  [:stop, :restart].each do |method|
    define_method(:"#{method}!") do |opts = {}|
      timeout = opts.delete('timeout')
      query = {}
      query['t'] = timeout if timeout
      connection.post(path_for(method), query, :body => opts.to_json)
      self
    end

    define_method(method) do |*args|
      begin; public_send(:"#{method}!", *args); rescue ServerError; self end
    end
  end

  # remove container
  def remove(options = {})
    connection.delete("/containers/#{self.id}", options)
    nil
  end
  alias_method :delete, :remove

  # pause and unpause containers
  # #pause! and #unpause! both perform the associated action and
  # return the Container. #pause and #unpause do the same,
  # but rescue from ServerErrors.
  [:pause, :unpause].each do |method|
    define_method(:"#{method}!") do
      connection.post path_for(method)
      self
    end

    define_method(method) do
      begin; public_send(:"#{method}!"); rescue ServerError; self; end
    end
  end

  def copy(path, &block)
    connection.post(path_for(:copy), {},
      :body => { "Resource" => path }.to_json,
      :response_block => block
    )
    self
  end

  # Create a new Container.
  def self.create(opts = {}, conn = Docker.connection)
    name = opts.delete('name')
    query = {}
    query['name'] = name if name
    resp = conn.post('/containers/create', query, :body => opts.to_json)
    hash = Docker::Util.parse_json(resp) || {}
    new(conn, hash)
  end

  # Return the container with specified ID
  def self.get(id, opts = {}, conn = Docker.connection)
    container_json = conn.get("/containers/#{URI.encode(id)}/json", opts)
    hash = Docker::Util.parse_json(container_json) || {}
    new(conn, hash)
  end

  # Return all of the Containers.
  def self.all(opts = {}, conn = Docker.connection)
    hashes = Docker::Util.parse_json(conn.get('/containers/json', opts)) || []
    hashes.map { |hash| new(conn, hash) }
  end

  # Convenience method to return the path for a particular resource.
  def path_for(resource)
    "/containers/#{self.id}/#{resource}"
  end

  private :path_for
  private_class_method :new
end
