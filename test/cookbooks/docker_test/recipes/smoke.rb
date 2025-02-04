#########################
# service named 'default'
#########################

docker_service 'default' do
  graph '/var/lib/docker'
  action [:create, :start]
end

################
# simple process
################

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

#####################
# squid forward proxy
#####################

directory '/etc/squid_forward_proxy' do
  recursive true
  owner 'root'
  mode '0755'
  action :create
end

template '/etc/squid_forward_proxy/squid.conf' do
  source 'squid_forward_proxy/squid.conf.erb'
  owner 'root'
  mode '0755'
  notifies :redeploy, 'docker_container[squid_forward_proxy]'
  action :create
end

docker_image 'ubuntu/squid' do
  tag 'latest'
  action :pull
end

docker_container 'squid_forward_proxy' do
  repo 'ubuntu/squid'
  tag 'latest'
  restart_policy 'on-failure'
  kill_after 5
  port '3128:3128'
  ulimits [
    { 'Name' => 'nofile', 'Soft' => 40_960, 'Hard' => 40_960 },
  ]
  volumes '/etc/squid_forward_proxy/squid.conf:/etc/squid/squid.conf'
  subscribes :redeploy, 'docker_image[ubuntu/squid]'
  action :run
end

#############
# service one
#############

docker_service 'one' do
  graph '/var/lib/docker-one'
  host 'unix:///var/run/docker-one.sock'
  http_proxy 'http://127.0.0.1:3128'
  https_proxy 'http://127.0.0.1:3128'
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

# Test case for digest image format
docker_container 'sha256-test' do
  repo 'hello-world'
  tag 'sha256:d715f14f9eca81473d9112df50457893aa4d099adeb4729f679006bf5ea12407'
  action :run
end
