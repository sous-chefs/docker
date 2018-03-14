module DockerCookbook
  class DockerBase < Chef::Resource
    require 'docker'
    require 'shellwords'

    ##########
    # coersion
    ##########
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

    def connection
      @connection ||= begin
                        opts = {}
                        opts[:read_timeout] = new_resource.read_timeout if new_resource.read_timeout
                        opts[:write_timeout] = new_resource.write_timeout if new_resource.write_timeout

                        if new_resource.host =~ /^tcp:/
                          opts[:scheme] = 'https' if new_resource.tls || !tls_verify.nil?
                          opts[:ssl_ca_file] = new_resource.tls_ca_cert if new_resource.tls_ca_cert
                          opts[:client_cert] = new_resource.tls_client_cert if new_resource.tls_client_cert
                          opts[:client_key] = new_resource.tls_client_key if new_resource.tls_client_key
                        end
                        Docker::Connection.new(new_resource.host || Docker.url, opts)
                      end
    end

    def with_retries(&_block)
      tries = new_resource.api_retries
      begin
        yield
      # Only catch errors that can be fixed with retries.
      rescue Docker::Error::ServerError, # 500
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

    property :tls, [TrueClass, FalseClass, nil], default: lazy { ENV['DOCKER_TLS'] }, desired_state: false
    property :tls_verify, [TrueClass, FalseClass, nil], default: lazy { ENV['DOCKER_TLS_VERIFY'] }, desired_state: false
    property :tls_ca_cert, [String, nil], default: lazy { "#{ENV['DOCKER_CERT_PATH']}/ca.pem" }, desired_state: false
    property :tls_server_cert, [String, nil], desired_state: false
    property :tls_server_key, [String, nil], desired_state: false
    property :tls_client_cert, [String, nil], default: lazy { "#{ENV['DOCKER_CERT_PATH']}/cert.pem" }, desired_state: false
    property :tls_client_key, [String, nil], default: lazy { "#{ENV['DOCKER_CERT_PATH']}/key.pem" }, desired_state: false

    declare_action_class.class_eval do
      # https://github.com/docker/docker/blob/4fcb9ac40ce33c4d6e08d5669af6be5e076e2574/registry/auth.go#L231
      def parse_registry_host(val)
        val.sub(%r{https?://}, '').split('/').first
      end
    end
  end
end
