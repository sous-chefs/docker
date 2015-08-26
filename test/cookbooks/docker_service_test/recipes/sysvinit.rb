docker_service 'default' do
  provider Chef::Provider::DockerService::Sysvinit
  action [:create, :start]
end
