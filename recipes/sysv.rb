settings_file =
  case node['platform']
  when 'debian', 'ubuntu' then '/etc/default/docker'
  else '/etc/sysconfig/docker'
  end

template '/etc/init.d/docker' do
  source 'docker.sysv.erb'
  mode '0755'
  owner 'root'
  group 'root'
end

template settings_file do
  source 'docker.sysconfig.erb'
  mode '0644'
  owner 'root'
  group 'root'
  variables(
    'daemon_options' => Helpers::Docker.daemon_cli_args(node)
  )
  notifies :restart, 'service[docker]', :immediately
end

service 'docker' do
  supports :status => true, :restart => true, :reload => true
  action [:start, :enable]
end
