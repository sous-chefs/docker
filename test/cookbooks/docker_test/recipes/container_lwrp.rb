docker_container "busybox" do
  command "sleep 1111"
  detach true
end

docker_container "busybox" do
  command "sleep 2222"
  detach true
end

docker_container "busybox" do
  command "sleep 3333"
  detach true
end

docker_container "busybox" do
  command "sleep 4444"
  detach true
end

docker_container "busybox" do
  command "sleep 5555"
  detach true
end

docker_container "busybox" do
  command "sleep 6666"
  port 80
  public_port 80
  detach true
end

docker_container "busybox" do
  command "sleep 2222"
  action :restart
end

docker_container "busybox" do
  command "sleep 3333"
  action :stop
end

docker_container "busybox" do
  command "sleep 4444"
  action :stop
end

docker_container "busybox" do
  command "sleep 4444"
  action :start
end

docker_container "busybox" do
  command "sleep 5555"
  action :remove
end
