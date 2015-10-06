require 'helpers_auth'

class Chef
  class Resource
    class DockerBase < ChefCompat::Resource
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
