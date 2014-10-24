# Package installation automatically starts docker service
# So let's stop and disable it.
service 'lxc-docker' do
  pattern Docker::Helpers.executable(node)
  provider Chef::Provider::Service::Upstart if node['platform'] == 'ubuntu'
  service_name Docker::Helpers.docker_service(node)
  action [:stop, :disable]
end

include_recipe 'runit'

runit_service 'docker' do
  default_logger true
  options(
    'daemon_options' => Docker::Helpers.daemon_cli_args(node)
  )
end
