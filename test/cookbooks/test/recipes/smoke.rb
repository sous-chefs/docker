# frozen_string_literal: true

#########################
# service named 'default'
#########################

docker_service 'default' do
  graph '/var/lib/docker'
  install_method 'none'
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

#############
# service one
#############
# Verify the cookbook can configure a second docker daemon on the same
# host. The earlier version of this test routed image pulls through a
# Squid forward proxy running in a container on the default daemon, but
# that pattern needs nested-docker isolation that doesn't fit a shared
# GHA runner. We keep just the two-daemons-coexist check.

docker_service 'one' do
  graph '/var/lib/docker-one'
  host 'unix:///var/run/docker-one.sock'
  install_method 'none'
  action [:create, :start]
end

###############
# digest image
###############

docker_image 'debian' do
  tag 'sha256:d6743b7859c917a488ca39f4ab5e174011305f50b44ce32d3b9ea5d81b291b3b'
end

docker_container 'sha256-test' do
  repo 'debian'
  tag 'sha256:d6743b7859c917a488ca39f4ab5e174011305f50b44ce32d3b9ea5d81b291b3b'
  command 'sleep infinity'
  action :run
end
