docker_container 'busybox' do
  command 'sleep 1111'
  detach true
  init_type false
end

docker_container 'busybox' do
  command 'sleep 2222'
  detach true
  init_type false
end

docker_container 'busybox' do
  command 'sleep 3333'
  detach true
  init_type false
end

docker_container 'busybox' do
  command 'sleep 4444'
  detach true
  init_type false
end

docker_container 'busybox' do
  command 'sleep 5555'
  detach true
  init_type false
end

docker_container 'busybox' do
  command 'sleep 6666'
  port '80:80'
  detach true
  init_type false
end

docker_container 'busybox' do
  command 'sleep 2222'
  init_type false
  action :restart
end

docker_container 'busybox' do
  command 'sleep 3333'
  init_type false
  action :stop
end

docker_container 'busybox' do
  command 'sleep 4444'
  init_type false
  action :stop
end

docker_container 'busybox' do
  command 'sleep 4444'
  init_type false
  action :start
end

docker_container 'busybox' do
  command 'sleep 5555'
  init_type false
  action :remove
end

directory '/mnt/docker' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# docker_container 'tduffield/testcontainerd' do
#   detach true
#   port '9999:9999'
# end

docker_container 'busybox-container' do
  image 'busybox'
  container_name 'busybox-container'
  command 'sleep 7777'
  detach true
  init_type false
end

docker_container 'busybox-container' do
  image 'busybox'
  container_name 'busybox-container'
  command 'sleep 8888'
  init_type false
  action :redeploy
end

docker_container 'busybox' do
  command 'sleep 9999'
  init_type false
  action :create
end

docker_container 'busybox2-container' do
  image 'busybox'
  container_name 'busybox2-container'
  command 'sleep 9777'
  detach true
  init_type false
  action :create
end

docker_container 'busybox2-container' do
  image 'busybox'
  container_name 'busybox2-container'
  command 'sleep 9888'
  init_type false
  action :redeploy
end
