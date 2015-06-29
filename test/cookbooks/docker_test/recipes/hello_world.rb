# hello_world.rb

docker_service 'default' do
  action [:create, :start]
end

docker_image 'busybox' do
  action :pull
end

docker_container 'an echo server' do
  image 'busybox'
  port '1234:1234'
  command 'nc -ll -p 1234 -e /bin/cat'
  detach true
  init_type false
end
