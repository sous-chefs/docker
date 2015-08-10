docker_service 'default' do
  provider Chef::Provider::DockerService::Execute
  action [:create, :start]
end
