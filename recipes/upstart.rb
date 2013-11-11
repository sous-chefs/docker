template '/etc/init/docker.conf' do
  source 'docker.conf.erb'
  mode '0600'
  owner 'root'
  group 'root'
  # lxc-docker package automatically starts service
  # must restart immediately to catch Upstart config changes after install
  notifies :restart, 'service[docker]', :immediately
end

service 'docker' do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :reload => true
  action [:start]
end
