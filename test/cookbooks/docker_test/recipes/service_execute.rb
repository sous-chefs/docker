#

docker_installation_binary 'default' do
  action :create
end

docker_service_manager_execute 'default' do
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
