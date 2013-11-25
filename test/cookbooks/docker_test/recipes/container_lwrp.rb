docker_container "busybox" do
  command "sleep 1111"
  detach true
  init_type false
end

docker_container "busybox" do
  command "sleep 2222"
  detach true
  init_type false
end

docker_container "busybox" do
  command "sleep 3333"
  detach true
  init_type false
end

docker_container "busybox" do
  command "sleep 4444"
  detach true
  init_type false
end

docker_container "busybox" do
  command "sleep 5555"
  detach true
  init_type false
end

docker_container "busybox" do
  command "sleep 6666"
  port '80:80'
  detach true
  init_type false
end

docker_container "busybox" do
  command "sleep 2222"
  init_type false
  action :restart
end

docker_container "busybox" do
  command "sleep 3333"
  init_type false
  action :stop
end

docker_container "busybox" do
  command "sleep 4444"
  init_type false
  action :stop
end

docker_container "busybox" do
  command "sleep 4444"
  init_type false
  action :start
end

docker_container "busybox" do
  command "sleep 5555"
  init_type false
  action :remove
end

directory '/mnt/docker' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

docker_container 'bflad/testcontainerd' do
  detach true
  port '9999:9999'
end
