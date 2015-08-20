################
# action :create
################

# create a container without starting it
docker_container 'hello-world' do
  command '/hello'
  action :create
end

#############
# action :run
#############

# This command will exit succesfully. This will happen on every
# chef-client run.
docker_container 'busybox_ls' do
  repo 'busybox'
  command 'ls -la /'
  not_if "[ ! -z `docker ps -qaf 'name=busybox_ls$'` ]"
  action :run
end

# The :run_if_missing action will only run once. It is the default
# action.
docker_container 'alpine_ls' do
  repo 'alpine'
  tag '3.1'
  command 'ls -la /'
  action :run_if_missing
end

###############
# port property
###############

# This process remains running between chef-client runs, :run will do
# nothing on subsequent converges.
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
  action :run
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
  not_if "[ ! -z `docker ps -qaf 'name=red_light$'` ]"
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
  not_if "[ ! -z `docker ps -qaf 'name=quitter$'` ]"
  action :run
end

docker_container 'quitter' do
  not_if { ::File.exist? '/marker_container_quitter_restarter' }
  action :restart
end

file '/marker_container_quitter_restarter' do
  action :create
end

# start a container to be restarted
execute 'restarter' do
  command 'docker run --name restarter -d busybox nc -ll -p 69 -e /bin/cat'
  not_if "[ ! -z `docker ps -qaf 'name=restarter$'` ]"
  action :run
end

docker_container 'restarter' do
  not_if { ::File.exist? '/marker_container_restarter' }
  action :restart
end

file '/marker_container_restarter' do
  action :create
end

################
# action :delete
################

# create a container to be deleted
execute 'deleteme' do
  command 'docker run --name deleteme -d busybox nc -ll -p 187 -e /bin/cat'
  not_if { ::File.exist?('/marker_container_deleteme') }
  action :run
end

file '/marker_container_deleteme' do
  action :create
end

docker_container 'deleteme' do
  action :delete
end

##################
# action :redeploy
##################

docker_container 'redeployer' do
  repo 'alpine'
  tag '3.1'
  command 'nc -ll -p 7777 -e /bin/cat'
  port '7'
  action :run
end

execute 'redeploy redeployer' do
  command 'touch /marker_container_redeployer'
  creates '/marker_container_redeployer'
  notifies :redeploy, 'docker_container[redeployer]', :immediately
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

# docker inspect -f "{{ .HostConfig.Binds }}"
docker_container 'bind_mounter' do
  repo 'busybox'
  command 'ls -la /bits /more-bits'
  binds ['/hostbits:/bits', '/more-hostbits:/more-bits']
  action :run_if_missing
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

docker_image 'chef_container' do
  tag 'latest'
  source '/chefbuilder'
  action :build_if_missing
end

# create a volume container
docker_container 'chef_container' do
  command 'true'
  volumes '/opt/chef'
  action :create
end

# Inspect the docker logs with test-kitchen bussers
docker_container 'ohai_debian' do
  command '/opt/chef/embedded/bin/ohai platform'
  repo 'debian'
  volumes_from 'chef_container'
end

#####
# env
#####

# Inspect container logs with test-kitchen bussers
docker_container 'env' do
  repo 'debian'
  env ['PATH=/usr/bin', 'FOO=bar']
  command 'env'
  action :run_if_missing
end

############
# entrypoint
############

# Inspect container logs with test-kitchen bussers
docker_container 'ohai_again' do
  repo 'debian'
  volumes_from 'chef_container'
  entrypoint '/opt/chef/embedded/bin/ohai'
  action :run_if_missing
end

docker_container 'ohai_again_debian' do
  repo 'debian'
  volumes_from 'chef_container'
  entrypoint '/opt/chef/embedded/bin/ohai'
  command 'platform'
  action :run_if_missing
end

##########
# cmd_test
##########
directory '/cmd_test' do
  action :create
end

file '/cmd_test/Dockerfile' do
  content <<-EOF
  FROM alpine
  # CMD '/bin/ls -la /'
  CMD ['/bin/ls', '-la', '/']
  EOF
  action :create
end

docker_image 'cmd_test' do
  tag 'latest'
  source '/cmd_test'
  action :build_if_missing
end

docker_container 'cmd_test' do
  action :run_if_missing
end

#############
# :autoremove
#############

# Inspect volume container with test-kitchen bussers
docker_container 'sean_was_here' do
  command "touch /opt/chef/sean_was_here-#{Time.new.strftime('%Y%m%d%H%M')}"
  repo 'debian'
  volumes_from 'chef_container'
  autoremove true
  not_if { ::File.exist? '/marker_container_sean_was_here' }
  action :run
end

# marker to prevent :run on subsequent converges.
file '/marker_container_sean_was_here' do
  action :create
end

#########
# cap_add
#########

# Inspect system with test-kitchen bussers
docker_container 'cap_add_net_admin' do
  repo 'debian'
  command 'bash -c "ip addr add 10.9.8.7/24 brd + dev eth0 label eth0:0 ; ip addr list"'
  cap_add 'NET_ADMIN'
  action :run_if_missing
end

docker_container 'cap_add_net_admin_error' do
  repo 'debian'
  command 'bash -c "ip addr add 10.9.8.7/24 brd + dev eth0 label eth0:0 ; ip addr list"'
  action :run_if_missing
end

##########
# cap_drop
##########

# Inspect container logs with test-kitchen bussers
docker_container 'cap_drop_mknod' do
  repo 'debian'
  command 'bash -c "mknod -m 444 /dev/urandom2 c 1 9 ; ls -la /dev/urandom2"'
  cap_drop 'MKNOD'
  action :run_if_missing
end

docker_container 'cap_drop_mknod_error' do
  repo 'debian'
  command 'bash -c "mknod -m 444 /dev/urandom2 c 1 9 ; ls -la /dev/urandom2"'
  action :run_if_missing
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
  action :run_if_missing
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
  action :run_if_missing
end

#############
# extra_hosts
#############

# Inspect container logs with test-kitchen bussers
docker_container 'extra_hosts' do
  repo 'debian'
  command 'cat /etc/hosts'
  extra_hosts ['east:4.3.2.1', 'west:1.2.3.4']
  action :run_if_missing
end

# #########
# # devices sans CAP_SYS_ADMIN
# #########

# # create file on disk
# execute 'create disk1 file' do
#   command 'dd if=/dev/zero of=/root/disk1 bs=1024 count=1'
#   creates '/root/disk1'
#   action :run
# end

# # create loop device
# execute 'create loop10 device' do
#   command 'losetup /dev/loop10 /root/disk1'
#   not_if 'losetup -l | grep ^/dev/loop10'
#   action :run
# end

# # host's /root/disk1 md5sum should match 0f343b0931126a20f133d67c2b018a3b
# docker_container 'devices_sans_cap_sys_admin' do
#   repo 'debian'
#   command 'sh -c "lsblk ; dd if=/dev/urandom of=/dev/loop10 bs=1024 count=1"'
#   devices [{
#     'PathOnHost' => '/dev/loop10',
#     'PathInContainer' => '/dev/loop10',
#     'CgroupPermissions' => 'rwm'
#   }]
#   action :run_if_missing
# end

# #########
# # devices with CAP_SYS_ADMIN
# #########

# # create file on disk
# execute 'create disk2 file' do
#   command 'dd if=/dev/zero of=/root/disk2 bs=1024 count=1'
#   creates '/root/disk2'
#   action :run
# end

# # create loop device
# execute 'create loop11 device' do
#   command 'losetup /dev/loop11 /root/disk2'
#   not_if 'losetup -l | grep ^/dev/loop11'
#   action :run
# end

# # host's /root/disk1 md5sum should NOT match 0f343b0931126a20f133d67c2b018a3b
# docker_container 'devices_with_cap_sys_admin' do
#   repo 'debian'
#   command 'sh -c "lsblk ; dd if=/dev/urandom of=/dev/loop11 bs=1024 count=1"'
#   devices [{
#     'PathOnHost' => '/dev/loop11',
#     'PathInContainer' => '/dev/loop11',
#     'CgroupPermissions' => 'rwm'
#   }]
#   cap_add 'SYS_ADMIN'
#   action :run_if_missing
# end

############
# cpu_shares
############

# docker inspect -f '{{ .HostConfig.CpuShares }}' cpu_shares
docker_container 'cpu_shares' do
  repo 'alpine'
  tag '3.1'
  command 'ls -la'
  cpu_shares 512
  action :run_if_missing
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
  action :run_if_missing
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
  action :run_if_missing
end

docker_container 'reboot_survivor' do
  repo 'alpine'
  tag '3.1'
  command 'nc -ll -p 123 -e /bin/cat'
  port '123'
  restart_policy 'always'
  action :run_if_missing
end

docker_container 'reboot_survivor_retry' do
  repo 'alpine'
  tag '3.1'
  command 'nc -ll -p 123 -e /bin/cat'
  port '123'
  restart_policy 'always'
  restart_maximum_retry_count 2
  action :run_if_missing
end

#######
# links
#######

# docker inspect -f "{{ .Config.Env }}" link_source
# docker inspect -f "{{ .NetworkSettings.IPAddress }}" link_source
docker_container 'link_source' do
  repo 'alpine'
  tag '3.1'
  env ['FOO=bar', 'BIZ=baz']
  command 'nc -ll -p 321 -e /bin/cat'
  port '321'
  action :run_if_missing
end

# docker inspect -f "{{ .HostConfig.Links }}" link_target_1
# docker inspect -f "{{ .Config.Env }}" link_target_1
docker_container 'link_target_1' do
  repo 'alpine'
  tag '3.1'
  env ['ASD=asd']
  command 'ping -c 1 hello'
  links ['link_source:hello']
  action :run_if_missing
end

# docker logs linker_target_2
docker_container 'link_target_2' do
  repo 'alpine'
  tag '3.1'
  command 'env'
  links ['link_source:hello']
  action :run_if_missing
end

# When we deploy the link_source container links are broken and we
# have to redeploy the linked containers to fix them.
execute 'redeploy_link_source' do
  command 'touch /marker_container_redeploy_link_source'
  creates '/marker_container_redeploy_link_source'
  notifies :redeploy, 'docker_container[link_source]', :immediately
  notifies :redeploy, 'docker_container[link_target_1]', :immediately
  notifies :redeploy, 'docker_container[link_target_2]', :immediately
  action :run
end

##############
# link removal
##############

# docker inspect -f "{{ .Volumes }}" another_link_source
# docker inspect -f "{{ .HostConfig.Links }}" another_link_source
docker_container 'another_link_source' do
  repo 'alpine'
  tag '3.1'
  command 'nc -ll -p 456 -e /bin/cat'
  port '456'
  action :run_if_missing
end

# docker inspect -f "{{ .HostConfig.Links }}" another_link_target
docker_container 'another_link_target' do
  repo 'alpine'
  tag '3.1'
  command 'ping -c 1 hello'
  links ['another_link_source:derp']
  action :run_if_missing
end

file '/marker_container_remover' do
  notifies :remove_link, 'docker_container[another_link_target]', :immediately
  action :create
end

################
# volume removal
################

directory '/dangler' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

file '/dangler/Dockerfile' do
  content <<-EOF
  FROM busybox
  RUN mkdir /stuff
  VOLUME /stuff
  EOF
  action :create
end

docker_image 'dangler' do
  tag 'latest'
  source '/dangler'
  action :build_if_missing
end

# create a volume container
docker_container 'dangler' do
  command 'true'
  not_if { ::File.exist?('/marker_container_dangler') }
  action :create
end

file '/marker_container_dangler' do
  action :create
end

# FIXME: this changed with 1.8.x. Find a way to sanely test across various platforms
#
# read this with a test-kitchen busser and make sure its gone.
# ruby_block 'stash dangler volpath on filesystem' do
#   block do
#     result = shell_out!('docker inspect -f "{{ .Volumes }}" dangler')
#     volpath = result.stdout.scan(/\[(.*?)\]/)[0][0].split(':')[1]
#     shell_out!("echo #{volpath} > /dangler_volpath")
#   end
#   not_if { ::File.exist?('/dangler_volpath') }
#   action :run
# end

docker_container 'dangler' do
  remove_volumes true
  action :delete
end

#########
# mutator
#########

docker_tag 'mutator_from_busybox' do
  target_repo 'busybox'
  target_tag 'latest'
  to_repo 'someara/mutator'
  target_tag 'latest'
end

docker_container 'mutator' do
  repo 'someara/mutator'
  tag 'latest'
  command "sh -c 'touch /mutator-`date +\"%Y-%m-%d_%H-%M-%S\"`'"
  outfile '/mutator.tar'
  force true
  action :run_if_missing
end

execute 'commit mutator' do
  command 'touch /marker_container_mutator'
  creates '/marker_container_mutator'
  notifies :commit, 'docker_container[mutator]', :immediately
  notifies :export, 'docker_container[mutator]', :immediately
  notifies :redeploy, 'docker_container[mutator]', :immediately
  action :run
end

##############
# network_mode
##############

docker_container 'network_mode' do
  repo 'alpine'
  tag '3.1'
  command 'nc -ll -p 777 -e /bin/cat'
  port '777:777'
  network_mode 'host'
  action :run
end
