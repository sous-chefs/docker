def wheezy?
  return true if node['platform'] == 'debian' && node['platform_version'].to_i == 7
  false
end

if wheezy?
  file '/etc/apt/sources.list.d/wheezy-backports.list' do
    content 'deb http://ftp.de.debian.org/debian wheezy-backports main'
    notifies :run, 'execute[wheezy apt update]', :immediately
    action :create
  end

  execute 'wheezy apt update' do
    command 'apt-get update'
    action :nothing
  end
end

# installation
docker_installation_package 'default' do
  action :create
end

# service named 'default'
docker_service_manager_sysvinit 'default' do
  graph '/var/lib/docker'
  action :start
end

docker_image 'busybox' do
  host 'unix:///var/run/docker.sock'
end

docker_container 'service default echo server' do
  container_name 'an_echo_server'
  repo 'busybox'
  command 'nc -ll -p 7 -e /bin/cat'
  port '7'
  action :run
end

# service A
docker_service_manager_sysvinit 'one' do
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
docker_service_manager_sysvinit 'two' do
  graph '/var/lib/docker-two'
  host 'unix:///var/run/docker-two.sock'
  action :start
end

docker_image 'alpine' do
  host 'unix:///var/run/docker-two.sock'
  tag '3.1'
end

docker_container 'service two echo_server' do
  container_name 'an_echo_server'
  repo 'alpine'
  tag '3.1'
  command 'nc -ll -p 7 -e /bin/cat'
  port '7'
  host 'unix:///var/run/docker-two.sock'
  action :run
end
