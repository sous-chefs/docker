# connects to docker daemon over defaults

docker_service 'default' do
  action [:create, :start]
end

docker_image 'alpine' do
  tag 'latest'
end

docker_container 'tcp' do
  repo 'alpine'
  command 'ls -la /'
end
