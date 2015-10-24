# connects to docker daemon over unix socket

docker_service 'default' do
  host ['unix:///var/run/docker.sock']
  action [:create, :start]
end

docker_image 'alpine' do
  host 'unix:///var/run/docker.sock'
  tag 'latest'
end

docker_container 'tcp' do
  host 'unix:///var/run/docker.sock'
  repo 'alpine'
  command 'ls -la /'
end
