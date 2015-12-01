docker_image 'alpine' do
  tag '3.1'
  action :pull_if_missing
end

docker_container 'network-container' do
  repo 'alpine'
  tag '3.1'
  command 'nc -ll -p 31337 -e /bin/cat'
  action :run
end

# Create a network without any settings
docker_network 'test-network' do
  action :create
end

# Create a overlay network
docker_network 'test-network-overlay' do
  driver 'overlay'
  action :create
end

# Create a network with specified subnet and gateway
docker_network 'test-network-ip' do
  subnet '192.168.88.0/24'
  gateway '192.168.88.3'
end

# Create a network with aux address
docker_network 'test-network-aux' do
  subnet '192.168.89.0/24'
  gateway '192.168.89.3'
  aux_address ['a=192.168.89.4', 'b=192.168.89.5']
end

# Connect a container to a network
docker_network 'test-network-aux-connect' do
  network_name 'test-network-aux'
  container 'network-container'
  action :connect
end

# Disconnect a container from a network
docker_network 'test-network-aux-disconnect' do
  network_name 'test-network-aux'
  container 'network-container'
  action :disconnect
end

# Remove a network
docker_network 'test-network-ip' do
  action :remove
end
