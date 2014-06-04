# Package installation automatically starts docker service
# So let's stop and disable it.
service 'lxc-docker' do
  pattern Helpers::Docker.executable(node)
  provider Chef::Provider::Service::Upstart if node['platform'] == 'ubuntu'
  service_name Helpers::Docker.docker_service(node)
  action [:stop, :disable]
end

include_recipe 'runit'

runit_service 'docker' do
  default_logger true
  options(
    'daemon_options' => Helpers::Docker.daemon_cli_args(node)
  )
end
