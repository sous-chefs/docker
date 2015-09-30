# comments!

execute_service_manager = true if node['docker']['service_manager'] == 'execute'

docker_service 'default' do
  tls false
  provider Chef::Provider::DockerService::Execute if execute_service_manager
  action [:create, :start]
end
