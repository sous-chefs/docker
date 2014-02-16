settings_file =
  case node['platform']
  when 'debian', 'ubuntu' then '/etc/default/docker'
  else '/etc/sysconfig/docker'
  end

template '/etc/init/docker.conf' do
  source 'docker.conf.erb'
  mode '0600'
  owner 'root'
  group 'root'
end

template settings_file do
  source 'docker.sysconfig.erb'
  mode '0644'
  owner 'root'
  group 'root'
  # DEPRECATED: stop and start only necessary for 0.x cookbook upgrades
  # Default docker Upstart job now sources default file for DOCKER_OPTS
  notifies :stop, 'service[docker]', :immediately
  notifies :start, 'service[docker]', :immediately
end

service 'docker' do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :reload => true
  action [:start]
end
