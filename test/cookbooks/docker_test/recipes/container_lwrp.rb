################
# action :create
################

# default action, default properties
docker_container 'hello-world' do
  command '/hello'
  action :create
end

#############
# action :run
#############

# This command will exit and the container will stop.
docker_container 'busybox_ls' do
  repo 'busybox'
  command 'ls -la /'
  action :run
  not_if { ::File.exist? '/tmp/container_marker_busybox_ls' }
  notifies :run, 'execute[container_marker_busybox_ls]', :immediately
end

# marker to prevent :run on subsequent converges.
execute 'container_marker_busybox_ls' do
  command 'touch /tmp/container_marker_busybox_ls'
  action :nothing
end

###############
# port property
###############

# a long running process
docker_container 'an_echo_server' do
  repo 'alpine'
  tag '3.1'
  command 'nc -ll -p 7 -e /bin/cat'
  port '7:7'
  action :run
end

# let docker pick the host port
docker_container 'another_echo_server' do
  repo 'alpine'
  tag '3.1'
  command 'nc -ll -p 7 -e /bin/cat'
  port '7'
  action :run
end

# specify the udp protocol
docker_container 'an_udp_echo_server' do
  repo 'alpine'
  tag '3.1'
  command 'nc -ul -p 7 -e /bin/cat'
  port '5007:7/udp'
  action :run
end

##############
# action :kill
##############

# start a container to be killed
execute 'bill' do
  command 'docker run --name bill -d busybox nc -ll -p 187 -e /bin/cat'
  not_if "[ ! -z `docker ps -qaf 'name=bill'` ]"
  not_if { ::File.exist? '/tmp/container_marker_bill' }
  notifies :run, 'execute[container_marker_bill]', :immediately
  action :run
end

# marker to prevent :run on subsequent converges.
execute 'container_marker_bill' do
  command 'touch /tmp/container_marker_bill'
  action :nothing
end

docker_container 'bill' do
  action :kill
end

##############
# action :stop
##############

# start a container to be stopped
execute 'hammer_time' do
  command 'docker run --name hammer_time -d busybox nc -ll -p 187 -e /bin/cat'
  not_if "[ ! -z `docker ps -qaf 'name=hammer_time'` ]"
  not_if { ::File.exist? '/tmp/container_marker_hammer_time' }
  notifies :run, 'execute[container_marker_hammer_time]', :immediately
  action :run
end

# marker to prevent :run on subsequent converges.
execute 'container_marker_hammer_time' do
  command 'touch /tmp/container_marker_hammer_time'
  action :nothing
end

docker_container 'hammer_time' do
  action :stop
end

###############
# action :pause
###############

# start a container to be paused
execute 'red_light' do
  command 'docker run --name red_light -d busybox nc -ll -p 42 -e /bin/cat'
  not_if "[ ! -z `docker ps -qaf 'name=red_light'` ]"
  not_if { ::File.exist? '/tmp/container_marker_red_light' }
  notifies :run, 'execute[container_marker_red_light]', :immediately
  action :run
end

# marker to prevent :run on subsequent converges.
execute 'container_marker_red_light' do
  command 'touch /tmp/container_marker_red_light'
  action :nothing
end

docker_container 'red_light' do
  action :pause
end

#################
# action :unpause
#################

# start and pause a container to be unpaused
bash 'green_light' do
  code <<-EOF
  docker run --name green_light -d busybox nc -ll -p 42 -e /bin/cat
  docker pause green_light
  EOF
  not_if "[ ! -z `docker ps -qaf 'name=green_light'` ]"
  not_if { ::File.exist? '/tmp/container_marker_green_light' }
  notifies :run, 'execute[container_marker_green_light]', :immediately
  action :run
end

# marker to prevent :run on subsequent converges.
execute 'container_marker_green_light' do
  command 'touch /tmp/container_marker_green_light'
  action :nothing
end

docker_container 'green_light' do
  action :unpause
end

#################
# action :restart
#################

# create and stop a container to be restarted
bash 'quitter' do
  code <<-EOF
  docker run --name quitter -d busybox nc -ll -p 69 -e /bin/cat
  docker kill quitter
  EOF
  not_if "[ ! -z `docker ps -qaf 'name=quitter'` ]"
  action :run
end

docker_container 'quitter' do
  not_if { ::File.exist? '/tmp/container_marker_quitter_restarter' }
  notifies :run, 'execute[container_marker_quitter_restarter]'
  action :restart
end

execute 'container_marker_quitter_restarter' do
  command 'touch /tmp/container_marker_quitter_restarter'
  action :nothing
end

# start a container to be restarted
bash 'restarter' do
  code <<-EOF
  docker run --name restarter -d busybox nc -ll -p 69 -e /bin/cat
  EOF
  not_if "[ ! -z `docker ps -qaf 'name=restarter'` ]"
  action :run
end

docker_container 'restarter' do
  not_if { ::File.exist? '/tmp/container_marker_restarter_restarter' }
  notifies :run, 'execute[container_marker_restarter_restarter]'
  action :restart
end

execute 'container_marker_restarter_restarter' do
  command 'touch /tmp/container_marker_restarter_restarter'
  action :nothing
end

################
# action :delete
################

# create a container to be deleted
execute 'deleteme' do
  command 'docker run --name deleteme -d busybox nc -ll -p 187 -e /bin/cat'
  not_if "[ ! -z `docker ps -qaf 'name=deleteme'` ]"
  not_if { ::File.exist?('/tmp/container_marker_deleteme') }
  notifies :run, 'execute[container_marker_deleteme]'
  action :run
end

execute 'container_marker_deleteme' do
  command 'touch /tmp/container_marker_deleteme'
  action :nothing
end

docker_container 'deleteme' do
  action :delete
end

##################
# action :redeploy
##################

execute 'redeploy an_echo_server' do
  command 'touch /tmp/container_marker_an_echo_server_redeploy'
  creates '/tmp/container_marker_an_echo_server_redeploy'
  notifies :redeploy, 'docker_container[an_echo_server]'
  action :run
end
