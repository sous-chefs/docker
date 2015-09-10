docker_service 'default' do
  tls false
  version node['docker']['version']
  action [:create, :start]
end
