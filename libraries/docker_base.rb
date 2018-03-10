module DockerCookbook
  class DockerBase < Chef::Resource
    require 'docker'
    require 'shellwords'

    ##########
    # coersion
    ##########

    def coerce_labels(v)
      case v
      when Hash, nil
        v
      else
        Array(v).each_with_object({}) do |label, h|
          parts = label.split(':')
          h[parts[0]] = parts[1..-1].join(':')
        end
      end
    end

    def coerce_shell_command(v)
      return nil if v.nil?
      return DockerBase::ShellCommandString.new(
        ::Shellwords.join(v)
      ) if v.is_a?(Array)
      DockerBase::ShellCommandString.new(v)
    end

    ################
    # Helper methods
    ################

    def api_version
      @api_version ||= Docker.version(connection)['ApiVersion']
    end

    def connection
      @connection ||= begin
                        opts = {}
                        opts[:read_timeout] = read_timeout if read_timeout
                        opts[:write_timeout] = write_timeout if write_timeout

                        if host =~ /^tcp:/
                          opts[:scheme] = 'https' if tls || !tls_verify.nil?
                          opts[:ssl_ca_file] = tls_ca_cert if tls_ca_cert
                          opts[:client_cert] = tls_client_cert if tls_client_cert
                          opts[:client_key] = tls_client_key if tls_client_key
                        end
                        Docker::Connection.new(host || Docker.url, opts)
                      end
    end

    def with_retries(&_block)
      tries = api_retries
      begin
        yield
        # Only catch errors that can be fixed with retries.
      rescue Docker::Error::ServerError, # 404
             Docker::Error::UnexpectedResponseError, # 400
             Docker::Error::TimeoutError,
             Docker::Error::IOError
        tries -= 1
        retry if tries > 0
        raise
      end
    end

    def call_action(_action)
      new_resource.run_action
    end

    def default_host
      return nil unless ENV['DOCKER_HOST']
      ENV['DOCKER_HOST']
    end

    def default_tls
      return nil unless ENV['DOCKER_TLS']
      ENV['DOCKER_TLS']
    end

    def default_tls_verify
      return nil unless ENV['DOCKER_TLS_VERIFY']
      ENV['DOCKER_TLS_VERIFY']
    end

    def default_tls_cert_path(v)
      return nil unless ENV['DOCKER_CERT_PATH']
      case v
      when 'ca'
        "#{ENV['DOCKER_CERT_PATH']}/ca.pem"
      when 'cert'
        "#{ENV['DOCKER_CERT_PATH']}/cert.pem"
      when 'key'
        "#{ENV['DOCKER_CERT_PATH']}/key.pem"
      end
    end

    #########
    # Classes
    #########

    class UnorderedArray < Array
      def ==(other)
        # If I (desired env) am a subset of the current env, let == return true
        other.is_a?(Array) && all? { |val| other.include?(val) }
      end
    end

    class ShellCommandString < String
      def ==(other)
        other.is_a?(String) && Shellwords.shellwords(self) == Shellwords.shellwords(other)
      end
    end

    class PartialHash < Hash
      def ==(other)
        other.is_a?(Hash) && all? { |key, val| other.key?(key) && other[key] == val }
      end
    end

    ################
    # Type Constants
    #
    # These will be used when declaring resource property types in the
    # docker_service, docker_container, and docker_image resource.
    #
    ################

    ArrayType = property_type(
      is: [Array, nil],
      coerce: proc { |v| v.nil? ? nil : Array(v) }
    ) unless defined?(ArrayType)

    NonEmptyArray = property_type(
      is: [Array, nil],
      coerce: proc { |v| Array(v).empty? ? nil : Array(v) }
    ) unless defined?(NonEmptyArray)

    ShellCommand = property_type(
      is: [String],
      coerce: proc { |v| coerce_shell_command(v) }
    ) unless defined?(ShellCommand)

    UnorderedArrayType = property_type(
      is: [UnorderedArray, nil],
      coerce: proc { |v| v.nil? ? nil : UnorderedArray.new(Array(v)) }
    ) unless defined?(UnorderedArrayType)

    PartialHashType = property_type(
      is: [PartialHash, nil],
      coerce: proc { |v| v.nil? ? nil : PartialHash[v] }
    ) unless defined?(PartialHashType)

    #####################
    # Resource properties
    #####################

    property :api_retries, Integer, default: 3, desired_state: false
    property :read_timeout, [Integer, nil], default: 60, desired_state: false
    property :write_timeout, [Integer, nil], desired_state: false
    property :running_wait_time, [Integer, nil], default: 20, desired_state: false

    property :tls, [TrueClass, FalseClass, nil], default: lazy { default_tls }, desired_state: false
    property :tls_verify, [TrueClass, FalseClass, nil], default: lazy { default_tls_verify }, desired_state: false
    property :tls_ca_cert, [String, nil], default: lazy { default_tls_cert_path('ca') }, desired_state: false
    property :tls_server_cert, [String, nil], desired_state: false
    property :tls_server_key, [String, nil], desired_state: false
    property :tls_client_cert, [String, nil], default: lazy { default_tls_cert_path('cert') }, desired_state: false
    property :tls_client_key, [String, nil], default: lazy { default_tls_cert_path('key') }, desired_state: false

    declare_action_class.class_eval do
      # https://github.com/docker/docker/blob/4fcb9ac40ce33c4d6e08d5669af6be5e076e2574/registry/auth.go#L231
      def parse_registry_host(val)
        val.sub(%r{https?://}, '').split('/').first
      end
    end
  end
end
