docker_installation_package 'default' do
  version node['docker']['version']
  action :create
end
