template '/etc/sysconfig/docker' do
  source 'docker.sysconfig.erb'
  mode '0644'
  owner 'root'
  group 'root'
  notifies :restart, 'service[docker]', :immediately
end

service 'docker' do
  supports :status => true, :restart => true, :reload => true
  action [:start, :enable]
end
