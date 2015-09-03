$LOAD_PATH.unshift *Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)]
require 'docker'

class Chef
  class Provider
    class DockerRegistry < Chef::Provider::LWRPBase
      provides :docker_registry if Chef::Provider.respond_to?(:provides)

      action :login do
        begin
          tries ||= new_resource.api_retries
          Docker.authenticate!(
            'serveraddress' => new_resource.serveraddress,
            'username' => new_resource.username,
            'password' => new_resource.password,
            'email' => new_resource.email
          )
        rescue Docker::Error::AuthenticationError
          if (tries -= 1).zero?
            raise Docker::Error::AuthenticationError, "#{new_resource.username} failed to authenticate with #{new_resource.serveraddress}"
          else
            retry
          end
        end
      end
    end
  end
end
