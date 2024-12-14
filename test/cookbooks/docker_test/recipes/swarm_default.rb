# This is a minimal default recipe for swarm testing
# It only installs Docker without the additional dependencies

docker_installation_script 'default' do
  repo node['docker']['repo']
  action :create
end

docker_service 'default' do
  action [:create, :start]
end
