docker_service 'default' do
  Chef::Provider::DockerService::Execute
  action [:create, :start]
end
