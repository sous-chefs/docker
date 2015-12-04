# installation
docker_installation_binary 'default' do
  action :create
end

# service A
docker_service_manager_execute 'one' do
  graph '/var/lib/docker-one'
  host 'unix:///var/run/docker-one.sock'
  action :start
end

docker_image 'hello-world' do
  host 'unix:///var/run/docker-one.sock'
  tag 'latest'
end

docker_container 'hello-world' do
  host 'unix:///var/run/docker-one.sock'
  command '/hello'
  action :create
end

# service B
docker_service_manager_execute 'two' do
  graph '/var/lib/docker-two'
  host 'unix:///var/run/docker-two.sock'
  action :start
end

docker_image 'alpine' do
  host 'unix:///var/run/docker-two.sock'
  tag '3.1'
end

docker_container 'an_echo_server' do
  repo 'alpine'
  tag '3.1'
  command 'nc -ll -p 7 -e /bin/cat'
  port '7:7'
  host 'unix:///var/run/docker-two.sock'
  action :run
end
