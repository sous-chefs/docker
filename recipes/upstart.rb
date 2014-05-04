def docker_settings_file
  case node['platform']
  when 'debian'
    '/etc/default/docker'
  when 'ubuntu'
    if Helpers::Docker.use_docker_ppa? node
      '/etc/default/docker'
    else
      '/etc/default/docker.io'
    end
  else
    '/etc/sysconfig/docker'
  end
end

def docker_upstart_conf_file
  case node['platform']
  when 'ubuntu'
    if Helpers::Docker.use_docker_ppa? node
      '/etc/init/docker.conf'
    else
      '/etc/init/docker.io.conf'
    end
  else
    '/etc/init/docker.conf'
  end
end

docker_service_name = ::File.basename(docker_upstart_conf_file, '.conf')

template docker_upstart_conf_file do
  source 'docker.conf.erb'
  mode '0600'
  owner 'root'
  group 'root'
end

template docker_settings_file do
  source 'docker.sysconfig.erb'
  mode '0644'
  owner 'root'
  group 'root'
  variables(
    'daemon_options' => Helpers::Docker.daemon_cli_args(node)
  )
  # DEPRECATED: stop and start only necessary for 0.x cookbook upgrades
  # Default docker Upstart job now sources default file for DOCKER_OPTS
  notifies :stop, "service[#{docker_service_name}]", :immediately
  notifies :start, "service[#{docker_service_name}]", :immediately
end

service docker_service_name do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :reload => true
  action [:start]
end

