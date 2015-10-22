docker_installation_binary 'default' do
  version node['docker']['version']
  action :create
end
