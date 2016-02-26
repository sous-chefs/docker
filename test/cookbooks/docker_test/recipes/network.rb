# pull alpine image
docker_image 'alpine' do
  tag '3.1'
  action :pull_if_missing
end

# unicode characters
docker_network 'seseme_straße' do
  action :create
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
  command 'nc -ll -p 31337 -e /bin/cat'
  port '31337'
  network_mode 'network_a'
  action :run
end

############
# network_b
############

execute 'create network_b' do
  command 'docker network create network_b'
  not_if { ::File.exist?('/marker_delete_network_b') }
end

file '/marker_delete_network_b' do
  action :create
end

# Delete a network
docker_network 'network_b' do
  action :delete
end

###########
# network_c
###########

# specify subnet and gateway
docker_network 'network_c' do
  subnet '192.168.88.0/24'
  gateway '192.168.88.1'
  action :create
end

# docker run --net=
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

# create a network with aux_address
docker_network 'network_d' do
  subnet '192.168.89.0/24'
  gateway '192.168.89.1'
  aux_address ['a=192.168.89.2', 'b=192.168.89.3']
end

docker_container 'echo-base-network_d' do
  repo 'alpine'
  tag '3.1'
  command 'nc -ll -p 1337 -e /bin/cat'
  port '1337'
  network_mode 'network_d'
  action :run
end

docker_container 'echo-station-network_d' do
  repo 'alpine'
  tag '3.1'
  command 'nc -ll -p 31337 -e /bin/cat'
  port '31337'
  network_mode 'network_d'
  action :run
end

###########
# network_e
###########

# specify overlay driver
docker_network 'network_e' do
  driver 'overlay'
  action :create
end

###########
# network_f
###########

# create a network with an ip-range
docker_network 'network_f' do
  driver 'bridge'
  subnet '172.28.0.0/16'
  gateway '172.28.5.254'
  ip_range '172.28.5.0/24'
end

docker_container 'echo-base-network_f' do
  repo 'alpine'
  tag '3.1'
  command 'nc -ll -p 1337 -e /bin/cat'
  port '1337'
  network_mode 'network_f'
  action :run
end

docker_container 'echo-station-network_f' do
  repo 'alpine'
  tag '3.1'
  command 'nc -ll -p 31337 -e /bin/cat'
  port '31337'
  network_mode 'network_f'
  action :run
end

###########
# network_g
###########

# create an overlay network with multiple subnets
docker_network 'network_g' do
  driver 'overlay'
  subnet ['192.168.0.0/16', '192.170.0.0/16']
  gateway ['192.168.0.100', '192.170.0.100']
  ip_range '192.168.1.0/24'
  aux_address ['a=192.168.1.5', 'b=192.168.1.6', 'a=192.170.1.5', 'b=192.170.1.6']
end

docker_container 'echo-base-network_g' do
  repo 'alpine'
  tag '3.1'
  command 'nc -ll -p 1337 -e /bin/cat'
  port '1337'
  network_mode 'network_g'
  action :run
end

docker_container 'echo-station-network_g' do
  repo 'alpine'
  tag '3.1'
  command 'nc -ll -p 31337 -e /bin/cat'
  port '31337'
  network_mode 'network_g'
  action :run
end
