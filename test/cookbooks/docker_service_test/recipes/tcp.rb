# connects to docker daemon over tcp with no encryption

docker_service 'default' do
  host 'tcp://0.0.0.0:2376'
  action [:create, :start]
end

docker_image 'alpine' do
  host 'tcp://127.0.0.1:2376'
  tag 'latest'
end

docker_container 'tcp' do
  host 'tcp://127.0.0.1:2376'
  repo 'alpine'
  command 'ls -la /'
end
