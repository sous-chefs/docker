execute 'systemctl-daemon-reload' do
  command '/bin/systemctl --system daemon-reload'
  action :nothing
end

template '/usr/lib/systemd/system/docker.socket' do
  source 'docker.socket.erb'
  mode '0644'
  owner 'root'
  group 'root'
end

template '/usr/lib/systemd/system/docker.service' do
  source 'docker.service.erb'
  mode '0644'
  owner 'root'
  group 'root'
  notifies :run, 'execute[systemctl-daemon-reload]', :immediately
  notifies :restart, 'service[docker]', :immediately
end

service 'docker' do
  provider Chef::Provider::Service::Systemd
  supports :status => true, :restart => true, :reload => true
  action [:start, :enable]
end
