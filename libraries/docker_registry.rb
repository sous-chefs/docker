require 'docker'
require 'helpers_auth'

class Chef
  class Resource
    class DockerRegistry < DockerBase
      use_automatic_resource_name

      property :api_retries, Fixnum, default: 3
      property :email, String
      property :password, String
      property :serveraddress, String, name_property: true
      property :username, String

      action :login do
        tries = new_resource.api_retries

        registry_host = parse_registry_host(new_resource.serveraddress)

        (node.run_state['docker_auth'] ||= {})[registry_host] = {
          'serveraddress' => registry_host,
          'username' => new_resource.username,
          'password' => new_resource.password,
          'email' => new_resource.email
        }

        begin
          Docker.connection.post(
            '/auth', {},
            body: node.run_state['docker_auth'][registry_host].to_json
          )
        rescue Docker::Error::ServerError, Docker::Error::UnauthorizedError
          if (tries -= 1).zero?
            raise Docker::Error::AuthenticationError, "#{new_resource.username} failed to authenticate with #{new_resource.serveraddress}"
          else
            retry
          end
        end

        true
      end
    end
  end
end
