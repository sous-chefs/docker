docker_service 'default' do
  tls false
  version node['docker']['version']
  # storage_driver 'overlay'
  action [:create, :start]
end
