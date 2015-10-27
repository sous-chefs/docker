#

docker_installation_package 'default' do
  action :create
end

docker_service_manager_upstart 'default' do
  host 'unix:///var/run/docker.sock'
  action :start
end

docker_image 'hello-world' do
  host 'unix:///var/run/docker.sock'
  tag 'latest'
end

docker_container 'hello-world' do
  host 'unix:///var/run/docker.sock'
  command '/hello'
  action :create
end
