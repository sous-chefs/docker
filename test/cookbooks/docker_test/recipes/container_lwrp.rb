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
  not_if "[ ! -z `docker ps -qaf 'name=busybox_ls$'` ]"
  action :run
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
  not_if "[ ! -z `docker ps -qaf 'name=bill$'` ]"
  notifies :run, 'execute[container_marker_bill]', :immediately
  action :run
end

# marker to prevent :run on subsequent converges.
execute 'container_marker_bill' do
  command 'touch /container_marker_bill'
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
  not_if "[ ! -z `docker ps -qaf 'name=hammer_time$'` ]"
  action :run
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
  action :run
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
  not_if "[ ! -z `docker ps -qaf 'name=green_light$'` ]"
  action :run
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
  not_if { ::File.exist? '/container_marker_quitter_restarter' }
  notifies :run, 'execute[container_marker_quitter_restarter]', :immediately
  action :restart
end

execute 'container_marker_quitter_restarter' do
  command 'touch /container_marker_quitter_restarter'
  action :nothing
end

# start a container to be restarted
bash 'restarter' do
  code <<-EOF
  docker run --name restarter -d busybox nc -ll -p 69 -e /bin/cat
  EOF
  not_if "[ ! -z `docker ps -qaf 'name=restarter$'` ]"
  action :run
end

docker_container 'restarter' do
  not_if { ::File.exist? '/container_marker_restarter_restarter' }
  notifies :run, 'execute[container_marker_restarter_restarter]', :immediately
  action :restart
end

execute 'container_marker_restarter_restarter' do
  command 'touch /container_marker_restarter_restarter'
  action :nothing
end

################
# action :delete
################

# create a container to be deleted
execute 'deleteme' do
  command 'docker run --name deleteme -d busybox nc -ll -p 187 -e /bin/cat'
  not_if "[ ! -z `docker ps -qaf 'name=deleteme'` ]"
  not_if { ::File.exist?('/container_marker_deleteme') }
  notifies :run, 'execute[container_marker_deleteme]', :immediately
  action :run
end

execute 'container_marker_deleteme' do
  command 'touch /container_marker_deleteme'
  action :nothing
end

docker_container 'deleteme' do
  action :delete
end

##################
# action :redeploy
##################

execute 'redeploy an_echo_server' do
  command 'touch /container_marker_an_echo_server_redeploy'
  creates '/container_marker_an_echo_server_redeploy'
  notifies :redeploy, 'docker_container[an_echo_server]', :immediately
  action :run
end

#############
# bind mounts
#############

directory '/hostbits' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

file '/hostbits/hello.txt' do
  content 'hello there\n'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

directory '/more-hostbits' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

file '/more-hostbits/hello.txt' do
  content 'hello there\n'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

# Inspect the docker logs with test-kitchen bussers
docker_container 'bind_mounter' do
  repo 'busybox'
  command 'ls -la /bits /more-bits'
  binds ['/hostbits:/bits', '/more-hostbits:/more-bits']
  not_if "[ ! -z `docker ps -qaf 'name=bind_mounter$'` ]"
  action :run
end

##############
# volumes_from
##############

# build a chef container
directory '/chefbuilder' do
  owner 'root'
  group 'root'
  action :create
end

execute 'copy chef to chefbuilder' do
  command 'tar cf - /opt/chef | tar xf - -C /chefbuilder'
  creates '/chefbuilder/opt'
  action :run
end

file '/chefbuilder/Dockerfile' do
  content <<-EOF
  FROM scratch
  ADD opt /opt
  EOF
  action :create
end

docker_image 'chef' do
  tag 'latest'
  source '/chefbuilder'
  action :build_if_missing
end

# start a volume container
docker_container 'chef' do
  command 'true'
  repo 'chef'
  volumes '/opt/chef'
  action :create
end

# mount it from another container
docker_image 'debian' do
  action :pull_if_missing
end

# Inspect the docker logs with test-kitchen bussers
docker_container 'ohai_debian' do
  command '/opt/chef/embedded/bin/ohai platform'
  repo 'debian'
  volumes_from 'chef'
  not_if "[ ! -z `docker ps -qaf 'name=ohai_debian$'` ]"
  action :run
end

#############
# :autoremove
#############

# Inspect volume container with test-kitchen bussers
docker_container 'sean_was_here' do
  command "touch /opt/chef/sean_was_here-#{Time.new.strftime('%Y%m%d%H%M')}"
  repo 'debian'
  volumes_from 'chef'
  autoremove true
  not_if { ::File.exist? '/container_marker_sean_was_here' }
  notifies :run, 'execute[container_marker_sean_was_here]', :immediately
  action :run
end

# marker to prevent :run on subsequent converges.
execute 'container_marker_sean_was_here' do
  command 'touch /container_marker_sean_was_here'
  action :nothing
end

#########
# cap_add
#########

# Inspect system with test-kitchen bussers
docker_container 'cap_add_net_admin' do
  repo 'debian'
  command 'bash -c "ip addr add 10.9.8.7/24 brd + dev eth0 label eth0:0 ; ip addr list"'
  cap_add 'NET_ADMIN'
  not_if "[ ! -z `docker ps -qaf 'name=cap_add_net_admin$'` ]"
  action :run
end

#######
# mknod
#######

# Inspect container logs with test-kitchen bussers
docker_container 'cap_drop_mknod' do
  repo 'debian'
  command 'bash -c "mknod -m 444 /dev/urandom2 c 1 9 ; ls -la /dev/urandom2"'
  cap_drop 'MKNOD'
  not_if "[ ! -z `docker ps -qaf 'name=cap_drop_mknod$'` ]"
  action :run
end

###########################
# host_name and domain_name
###########################

# Inspect container logs with test-kitchen bussers
docker_container 'fqdn' do
  repo 'debian'
  command 'hostname -f'
  host_name 'computers'
  domain_name 'biz'
  not_if "[ ! -z `docker ps -qaf 'name=fqdn$'` ]"
  action :run
end

#####
# dns
#####

# Inspect container logs with test-kitchen bussers
docker_container 'dns' do
  repo 'debian'
  command 'cat /etc/resolv.conf'
  host_name 'computers'
  dns ['4.3.2.1', '1.2.3.4']
  dns_search ['computers.biz', 'chef.io']
  not_if "[ ! -z `docker ps -qaf 'name=dns$'` ]"
  action :run
end

#############
# extra_hosts
#############

# Inspect container logs with test-kitchen bussers
docker_container 'extra_hosts' do
  repo 'debian'
  command 'cat /etc/hosts'
  extra_hosts ['east:4.3.2.1', 'west:1.2.3.4']
  not_if "[ ! -z `docker ps -qaf 'name=extra_hosts$'` ]"
  action :run
end

############
# entrypoint
############

# Inspect container logs with test-kitchen bussers
docker_container 'ohai_again_debian' do
  repo 'debian'
  volumes_from 'chef'
  entrypoint '/opt/chef/embedded/bin/ohai'
  command 'platform'
  not_if "[ ! -z `docker ps -qaf 'name=ohai_again_debian$'` ]"
  action :run
end

#####
# env
#####

# Inspect container logs with test-kitchen bussers
docker_container 'env' do
  repo 'debian'
  env ['PATH=/usr/bin', 'FOO=bar']
  command 'env'
  not_if "[ ! -z `docker ps -qaf 'name=env$'` ]"
  action :run
end

#########
# devices
#########

# create file on disk
execute 'create disk file' do
  command 'dd if=/dev/zero of=/root/disk1 bs=1024 count=1'
  creates '/root/disk1'
  action :run
end

# create loop device
execute 'create loop device' do
  command 'losetup /dev/loop1 /root/disk1'
  not_if 'losetup -l | grep ^/dev/loop1'
  action :run
end

# host's /root/disk1 md5sum should NOT match 0f343b0931126a20f133d67c2b018a3b
docker_container 'devices' do
  repo 'debian'
  command 'sh -c "lsblk ; dd if=/dev/urandom of=/dev/loop1 bs=1024 count=1"'
  devices [{
    'PathOnHost' => '/dev/loop1',
    'PathInContainer' => '/dev/loop1',
    'CgroupPermissions' => 'rwm'
  }]
  cap_add 'SYS_ADMIN'
  not_if "[ ! -z `docker ps -qaf 'name=devices$'` ]"
  action :run
end

############
# cpu_shares
############

# docker inspect cpu_shares | grep '"CpuShares": 512'
docker_container 'cpu_shares' do
  repo 'alpine'
  tag '3.1'
  command 'ls -la'
  cpu_shares 512
  not_if "[ ! -z `docker ps -qaf 'name=cpu_shares$'` ]"
  action :run
end

#############
# cpuset_cpus
#############

# docker inspect cpu_shares | grep '"CpusetCpus": "0,1"'
docker_container 'cpuset_cpus' do
  repo 'alpine'
  tag '3.1'
  command 'ls -la'
  cpuset_cpus '0,1'
  not_if "[ ! -z `docker ps -qaf 'name=cpuset_cpus$'` ]"
  action :run
end

################
# restart_policy
################

# docker inspect restart_policy | grep 'RestartPolicy'
docker_container 'try_try_again' do
  repo 'alpine'
  tag '3.1'
  command 'grep asdasdasd /etc/passwd'
  restart_policy 'on-failure'
  restart_maximum_retry_count 2
  not_if "[ ! -z `docker ps -qaf 'name=restart_policy_try_try_again$'` ]"
  action :run
end

docker_container 'reboot_survivor' do
  repo 'alpine'
  tag '3.1'
  command 'nc -ll -p 123 -e /bin/cat'
  port '123'
  restart_policy 'always'
  not_if "[ ! -z `docker ps -qaf 'name=reboot_survivor$'` ]"
  action :run
end

docker_container 'reboot_survivor_retry' do
  repo 'alpine'
  tag '3.1'
  command 'nc -ll -p 123 -e /bin/cat'
  port '123'
  restart_policy 'always'
  restart_maximum_retry_count 2
  not_if "[ ! -z `docker ps -qaf 'name=reboot_survivor_retry$'` ]"
  action :run
end
