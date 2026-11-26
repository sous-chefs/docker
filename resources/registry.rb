# frozen_string_literal: true

unified_mode true
use '_partial/_base'

resource_name :docker_registry
provides :docker_registry

property :email, String

property :password, String,
          sensitive: true

property :serveraddress, String,
          name_property: true

property :repository_prefix, String,
          regex: %r{\A[a-z0-9][a-z0-9._-]*(?:/[a-z0-9][a-z0-9._-]*)*\z},
          desired_state: false

property :username, String

property :host,
          [String, nil],
          default: lazy { ENV['DOCKER_HOST'] },
          desired_state: false

action :login do
  tries = new_resource.api_retries

  registry_host = parse_registry_host(new_resource.serveraddress)
  if new_resource.repository_prefix && registry_host != registry_authority(new_resource.serveraddress)
    raise Chef::Exceptions::ValidationFailed, 'repository_prefix requires an explicit registry address with a qualified hostname, a port, or localhost'
  end

  credentials = {
    'serveraddress' => registry_host,
    'username' => new_resource.username,
    'password' => new_resource.password,
    'email' => new_resource.email,
  }

  begin
    connection.post(
      '/auth', {},
      body: credentials.to_json
    )
  rescue Docker::Error::ServerError, Docker::Error::UnauthorizedError
    raise Docker::Error::AuthenticationError, "#{new_resource.username} failed to authenticate with #{new_resource.serveraddress}" if (tries -= 1) == 0
    retry
  end

  if new_resource.repository_prefix
    repository_auth = node.run_state['docker_repository_auth'] ||= {}
    (repository_auth[repository_auth_host(registry_host)] ||= {})[new_resource.repository_prefix] = credentials
  else
    (node.run_state['docker_auth'] ||= {})[registry_host] = credentials
  end

  true
end
