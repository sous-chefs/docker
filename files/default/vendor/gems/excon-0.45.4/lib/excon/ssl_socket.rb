module Excon
  class SSLSocket < Socket
    HAVE_NONBLOCK = [:connect_nonblock, :read_nonblock, :write_nonblock].all? do |m|
      OpenSSL::SSL::SSLSocket.public_method_defined?(m)
    end

    def initialize(data = {})
      super

      # create ssl context
      ssl_context = OpenSSL::SSL::SSLContext.new

      # disable less secure options, when supported
      ssl_context_options = OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:options]
      if defined?(OpenSSL::SSL::OP_DONT_INSERT_EMPTY_FRAGMENTS)
        ssl_context_options &= ~OpenSSL::SSL::OP_DONT_INSERT_EMPTY_FRAGMENTS
      end

      if defined?(OpenSSL::SSL::OP_NO_COMPRESSION)
        ssl_context_options |= OpenSSL::SSL::OP_NO_COMPRESSION
      end
      ssl_context.options = ssl_context_options

      ssl_context.ciphers = @data[:ciphers]
      if @data[:ssl_version]
        ssl_context.ssl_version = @data[:ssl_version]
      end

      if @data[:ssl_verify_peer]
        # turn verification on
        ssl_context.verify_mode = OpenSSL::SSL::VERIFY_PEER

        if ca_file = @data[:ssl_ca_file] || ENV['SSL_CERT_FILE']
          ssl_context.ca_file = ca_file
        end
        if ca_path = @data[:ssl_ca_path] || ENV['SSL_CERT_DIR']
          ssl_context.ca_path = ca_path
        end
        if cert_store = @data[:ssl_cert_store]
          ssl_context.cert_store = cert_store
        end

        # no defaults, fallback to bundled
        unless ca_file || ca_path || cert_store
          ssl_context.cert_store = OpenSSL::X509::Store.new
          ssl_context.cert_store.set_default_paths

          # workaround issue #257 (JRUBY-6970)
          ca_file = DEFAULT_CA_FILE
          ca_file.gsub!(/^jar:/, '') if ca_file =~ /^jar:file:\//

          begin
            ssl_context.cert_store.add_file(ca_file)
          rescue
            Excon.display_warning("Excon unable to add file to cert store, ignoring: #{ca_file}\n[#{$!.class}] #{$!.message}")
          end
        end

        if verify_callback = @data[:ssl_verify_callback]
          ssl_context.verify_callback = verify_callback
        end
      else
        # turn verification off
        ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      # maintain existing API
      certificate_path = @data[:client_cert] || @data[:certificate_path]
      private_key_path = @data[:client_key] || @data[:private_key_path]
      private_key_pass = @data[:client_key_pass] || @data[:private_key_pass]

      if certificate_path && private_key_path
        ssl_context.cert = OpenSSL::X509::Certificate.new(File.read(certificate_path))
        if OpenSSL::PKey.respond_to? :read
          ssl_context.key = OpenSSL::PKey.read(File.read(private_key_path), private_key_pass)
        else
          ssl_context.key = OpenSSL::PKey::RSA.new(File.read(private_key_path), private_key_pass)
        end
      elsif @data.key?(:certificate) && @data.key?(:private_key)
        ssl_context.cert = OpenSSL::X509::Certificate.new(@data[:certificate])
        if OpenSSL::PKey.respond_to? :read
          ssl_context.key = OpenSSL::PKey.read(@data[:private_key], private_key_pass)
        else
          ssl_context.key = OpenSSL::PKey::RSA.new(@data[:private_key], private_key_pass)
        end
      end

      if @data[:proxy]
        request = 'CONNECT ' << @data[:host] << port_string(@data.merge(:omit_default_port => false)) << Excon::HTTP_1_1
        request << 'Host: ' << @data[:host] << port_string(@data) << Excon::CR_NL

        if @data[:proxy][:password] || @data[:proxy][:user]
          auth = ['' << @data[:proxy][:user].to_s << ':' << @data[:proxy][:password].to_s].pack('m').delete(Excon::CR_NL)
          request << 'Proxy-Authorization: Basic ' << auth << Excon::CR_NL
        end

        request << 'Proxy-Connection: Keep-Alive' << Excon::CR_NL

        request << Excon::CR_NL

        # write out the proxy setup request
        @socket.write(request)

        # eat the proxy's connection response
        Excon::Response.parse(self,  :expects => 200, :method => 'CONNECT')
      end

      # convert Socket to OpenSSL::SSL::SSLSocket
      @socket = OpenSSL::SSL::SSLSocket.new(@socket, ssl_context)
      @socket.sync_close = true

      # Server Name Indication (SNI) RFC 3546
      if @socket.respond_to?(:hostname=)
        @socket.hostname = @data[:host]
      end

      begin
        if @nonblock
          begin
            @socket.connect_nonblock
          rescue Errno::EAGAIN, Errno::EWOULDBLOCK, IO::WaitReadable
            IO.select([@socket])
            retry
          rescue IO::WaitWritable
            IO.select(nil, [@socket])
            retry
          end
        else
          @socket.connect
        end
      rescue Errno::ETIMEDOUT, Timeout::Error
        raise Excon::Errors::Timeout.new('connect timeout reached')
      end

      # verify connection
      if @data[:ssl_verify_peer]
        @socket.post_connection_check(@data[:ssl_verify_peer_host] || @data[:host])
      end

      @socket
    end

    private

    def connect
      # backwards compatability for things lacking nonblock
      @nonblock = HAVE_NONBLOCK && @nonblock
      super
    end
  end
end
