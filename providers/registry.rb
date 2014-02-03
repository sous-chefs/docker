require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut
include Helpers::Docker

class CommandTimeout < RuntimeError; end

def load_current_resource
  @current_resource = Chef::Resource::DockerRegistry.new(new_resource)
  wait_until_ready!
  # TODO: load current resource?
  @current_resource
end

action :login do
  unless logged_in?
    login
    new_resource.updated_by_last_action(true)
  end
end

def command_timeout_error_message
  <<-EOM

Command timed out:
#{cmd}

Please adjust node registry_cmd_timeout attribute or this docker_registry cmd_timeout attribute if necessary.
EOM
end

def logged_in?
  @current_resource || true
end

def login
  login_args = cli_args(
    'e' => new_resource.email,
    'p' => new_resource.password,
    'u' => new_resource.username
  )
  docker_cmd("login #{new_resource.server} #{login_args}")
end
