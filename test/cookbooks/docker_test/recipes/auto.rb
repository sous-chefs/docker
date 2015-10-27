
################
# Docker service
################

docker_service 'default' do
  host 'unix:///var/run/docker.sock'
  install_method 'auto'
  service_manager 'auto'
  action [:create, :start]
end
