# hello_world.rb

docker_service 'default' do
  action [:create, :start]
end

docker_image 'busybox' do
  action :pull_if_missing
end

docker_container 'echo_server' do
  image 'busybox'
  port '1234:1234'
  command 'nc -ll -p 1234 -e /bin/cat'
  action :run
end
