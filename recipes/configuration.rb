template "#{node['docker']['config_dir']}/docker" do
  source 'docker.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[docker]', :immediately
end
