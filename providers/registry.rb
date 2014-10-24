include Docker::Helpers

def load_current_resource
  @current_resource = Chef::Resource::DockerRegistry.new(new_resource.name)
  wait_until_ready!
  dockercfg = dockercfg_parse
  if dockercfg && login_matches(dockercfg[new_resource.server])
    Chef::Log.debug("Matched registry login: #{new_resource.server}: #{dockercfg[new_resource.server]}")
    @current_resource.server(new_resource.server)
    @current_resource.username(dockercfg[new_resource.server]['username'])
    @current_resource.password(dockercfg[new_resource.server]['password'])
  end
  @current_resource
end

action :login do
  unless logged_in?
    login
    new_resource.updated_by_last_action(true)
  end
end

def command_timeout_error_message(cmd)
  <<-EOM

Command timed out:
#{cmd}

Please adjust node registry_cmd_timeout attribute or this docker_registry cmd_timeout attribute if necessary.
EOM
end

def logged_in?
  @current_resource.username ? true : false
end

def login
  login_args = cli_args(
    'email' => new_resource.email,
    'password' => new_resource.password,
    'username' => new_resource.username
  )
  docker_cmd!("login #{login_args} #{new_resource.server} ")
end

def login_matches(cfg)
  return false unless cfg
  cfg['username'] == new_resource.username && cfg['password'] == new_resource.password
end
