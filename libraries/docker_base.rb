require 'helpers_auth'
require 'shellwords'

class Chef
  class Resource
    class DockerBase < ChefCompat::Resource
      ################
      # Constants
      #
      # These will be used when declaring resource property types in the
      # docker_service, docker_container, and docker_image resource.
      #
      ################

      ArrayType = property_type(
        is: [Array, nil],
        coerce: proc { |val| val.nil? ? nil : Array(val) }
      ) unless defined?(ArrayType)

      Boolean = property_type(
        is: [true, false],
        default: false
      ) unless defined?(Boolean)

      NonEmptyArray = property_type(
        is: [Array, nil],
        coerce: proc { |val| Array(val).empty? ? nil : Array(val) }
      ) unless defined?(NonEmptyArray)

      ShellCommand = property_type(
        is: [String, nil],
        coerce: proc { |val| coerce_shell_command(val) }
      ) unless defined?(ShellCommand)

      UnorderedArrayType = property_type(
        is: [Array, nil],
        coerce: proc { |val| val.nil? ? nil : UnorderedArray.new(Array(val)) }
      ) unless defined?(UnorderedArray)

      #########
      # Classes
      #########

      class UnorderedArray < Array
        def ==(other)
          # If I (desired env) am a subset of the current env, let == return true
          other.is_a?(Array) && self.all? { |val| other.include?(val) }
        end
      end

      class ShellCommandString < String
        def ==(other)
          other.is_a?(String) && Shellwords.shellwords(self) == Shellwords.shellwords(other)
        end
      end

      ##########
      # coersion
      ##########

      def coerce_labels(val)
        case val
        when Hash, nil
          val
        else
          Array(val).each_with_object({}) do |label, h|
            parts = label.split(':')
            h[parts[0]] = parts[1]
          end
        end
      end

      def coerce_shell_command(val)
        return nil if val.nil?
        return ShellCommandString.new(::Shellwords.join(val)) if val.is_a?(Array)
        ShellCommandString.new(val)
      end

      ################
      # Helper methods
      ################

      def to_port_exposures(ports)
        return nil if ports.nil?
        Array(ports).inject({}) { |a, e| a.merge(PortBinding.new(e).exposure) }
      end

      def to_port_bindings(ports)
        return nil if ports.nil?
        Array(ports).inject({}) { |a, e| a.merge(PortBinding.new(e).binding) }
      end

      def api_version
        @api_version ||= Docker.version['ApiVersion']
      end

      def connection
        @connection ||= begin
                          opts = {}
                          opts['read_timeout'] = read_timeout if property_is_set?(:read_timeout)
                          opts['write_timeout'] = write_timeout if property_is_set?(:write_timeout)
                          Docker::Connection.new(host || Docker.url, opts)
                        end
      end

      def with_retries(&block)
        tries = api_retries
        begin
          block.call
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

      #####################
      # Resource properties
      #####################

      property :api_retries,       Fixnum,        default: 3, desired_state: false
      property :read_timeout,      [Fixnum, nil], default: 60, desired_state: false
      property :write_timeout,     [Fixnum, nil], desired_state: false

      declare_action_class.class_eval do
        include DockerHelpers::Authentication
      end
    end
  end
end
