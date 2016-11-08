
################
# Docker service
################

docker_service 'default' do
  install_method 'tarball'
  version node['docker']['version']
  action [:create, :start]
end
