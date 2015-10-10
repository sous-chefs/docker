require 'helpers_auth'
require 'helpers_base'

class Chef
  class Resource
    class DockerBase < ChefCompat::Resource
      include DockerHelpers::Base

      ################
      # Constants
      #
      # These will be used when declaring resource property types in the
      # docker_service, docker_container, and docker_image resource.
      #
      ################

      ArrayType = property_type(
        is: [Array, nil],
        coerce: proc { |v| v.nil? ? nil : Array(v) }
      ) unless defined?(ArrayType)

      Boolean = property_type(
        is: [true, false],
        default: false
      ) unless defined?(Boolean)

      NonEmptyArray = property_type(
        is: [Array, nil],
        coerce: proc { |v| Array(v).empty? ? nil : Array(v) }
      ) unless defined?(NonEmptyArray)

      ShellCommand = property_type(
        is: [String, nil],
        coerce: proc { |v| coerce_shell_command(v) }
      ) unless defined?(ShellCommand)

      UnorderedArrayType = property_type(
        is: [Array, nil],
        coerce: proc { |v| v.nil? ? nil : UnorderedArray.new(Array(v)) }
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
