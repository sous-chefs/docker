docker_service_sysvinit 'default' do
  action [:create, :start]
end
