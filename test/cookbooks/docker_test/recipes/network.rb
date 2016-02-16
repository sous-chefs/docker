# pull alpine image
docker_image 'alpine' do
  tag '3.1'
  action :pull_if_missing
end

###########
# network_a
###########

# defaults
docker_network 'network_a' do
  action :create
end

# docker run --net=
docker_container 'echo-base-network_a' do
  repo 'alpine'
  tag '3.1'
  command 'nc -ll -p 1337 -e /bin/cat'
  port '1337'
  network_mode 'network_a'
  action :run
end

docker_container 'echo-station-network_a' do
  repo 'alpine'
  tag '3.1'
  network_mode 'network_a'
  command 'sleep 120'
  action :run
end

###########
# network_b
###########

# specify subnet and gateway
docker_network 'network_b' do
  subnet '192.168.88.0/24'
  gateway '192.168.88.1'
  action :create
end

# docker run --net=
docker_container 'echo-base-network_b' do
  repo 'alpine'
  tag '3.1'
  command 'nc -ll -p 1337 -e /bin/cat'
  port '1337'
  network_mode 'network_b'
  action :run
end

docker_container 'echo-station-network_b' do
  repo 'alpine'
  tag '3.1'
  command 'nc -ll -p 31337 -e /bin/cat'
  port '31337'
  network_mode 'network_b'
  action :run
end

###########
# network_c
###########

# create a network with aux_address
docker_network 'network_c' do
  subnet '192.168.89.0/24'
  gateway '192.168.89.1'
  aux_address ['a=192.168.89.2', 'b=192.168.89.3']
end

# ^ Broken... here is the Docker CLI version for reference

# docker network create \
#  --subnet 192.168.89.0/24 \
#  --gateway=192.168.89.1 \
#  --aux-address a=192.168.89.2 \
#  --aux-address b=192.168.89.3 \
#  network_c

docker_container 'echo-base-network_c' do
  repo 'alpine'
  tag '3.1'
  command 'nc -ll -p 1337 -e /bin/cat'
  port '1337'
  network_mode 'network_c'
  action :run
end

docker_container 'echo-station-network_c' do
  repo 'alpine'
  tag '3.1'
  command 'nc -ll -p 31337 -e /bin/cat'
  port '31337'
  network_mode 'network_c'
  action :run
end

###########
# network_d
###########

# specify overlay driver
docker_network 'network_d' do
  driver 'overlay'
  action :create
end

#######################
# FIXME - Remove these?
# Perhaps a docker_network_connection resource would be more appropriate.
#
###################

# # Connect a container to a network
# docker_network 'test-network-aux-connect' do
#   network_name 'test-network-aux'
#   container 'network-container'
#   action :connect
# end

# # Disconnect a container from a network
# docker_network 'test-network-aux-disconnect' do
#   network_name 'test-network-aux'
#   container 'network-container'
#   action :disconnect
# end

# # Delete a network
docker_network 'test-network-ip-range' do
  subnet '192.168.90.0/24'
  ip_range '192.168.90.32/28'
end

# Connect a container to a network
docker_network 'test-network-connect' do
  container 'network-container'
  action [:create, :connect]
end

# Disconnect a container from a network
# docker_network 'test-network-aux-disconnect' do
#   network_name 'test-network-aux'
#   container 'network-container'
#   action :disconnect
# end

# Delete a network
# docker_network 'delete-test-network-ip' do
#   network_name 'test-network-ip'
#   action :delete
# end
