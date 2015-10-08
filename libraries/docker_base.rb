require 'helpers_auth'
require 'shellwords'

class Chef
  class Resource
    class DockerBase < ChefCompat::Resource
      ShellCommand = property_type(is: String, coerce: proc { |v| v.is_a?(Array) ? ::Shellwords.join(v) : v })
      NonEmptyArray = property_type(is: [Array, nil], coerce: proc { |v| Array(v).empty? ? nil : Array(v) })
      NullableArray = property_type(is: [Array, nil], coerce: proc { |v| v.nil? ? nil : Array(v) })
      ArrayType = property_type(is: Array, coerce: proc { |v| Array(v) })
      Boolean = property_type(is: [true, false], default: false)

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

      declare_action_class.class_eval do
        include DockerHelpers::Authentication
      end
    end
  end
end
