docker_settings_file = Docker::Helpers.docker_settings_file(node)
docker_upstart_conf_file = Docker::Helpers.docker_upstart_conf_file(node)
docker_service = Docker::Helpers.docker_service(node)

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
    'daemon_options' => Docker::Helpers.daemon_cli_args(node)
  )
  # DEPRECATED: stop and start only necessary for 0.x cookbook upgrades
  # Default docker Upstart job now sources default file for DOCKER_OPTS
  notifies :stop, "service[#{docker_service}]", :immediately
  notifies :start, "service[#{docker_service}]", :immediately
end

service docker_service do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :reload => true
  action [:start]
end
