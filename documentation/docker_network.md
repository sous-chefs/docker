# docker_network

The `docker_network` resource is responsible for managing Docker named networks. Usage of `overlay` driver requires the `docker_service` to be configured to use a distributed key/value store like `etcd`, `consul`, or `zookeeper`.

## Actions

- `:create` - create a network
- `:delete` - delete a network
- `:connect` - connect a container to a network
- `:disconnect` - disconnect a container from a network

## Properties

- `aux_address` - Auxiliary addresses for the network. Ex: `['a=192.168.1.5', 'b=192.168.1.6']`
- `container` - Container-id/name to be connected/disconnected to/from the network. Used only by `:connect` and `:disconnect` actions
- `driver` - The network driver to use. Defaults to `bridge`, other options include `overlay`.
- `enable_ipv6` - Enable IPv6 on the network. Ex: true
- `gateway` - Specify the gateway(s) for the network. Ex: `192.168.0.1`
- `ip_range` - Specify a range of IPs to allocate for containers. Ex: `192.168.1.0/24`
- `subnet` - Specify the subnet(s) for the network. Ex: `192.168.0.0/16`

## Examples

Create a network and use it in a container

```ruby
docker_network 'network_g' do
  driver 'overlay'
  subnet ['192.168.0.0/16', '192.170.0.0/16']
  gateway ['192.168.0.100', '192.170.0.100']
  ip_range '192.168.1.0/24'
  aux_address ['a=192.168.1.5', 'b=192.168.1.6', 'a=192.170.1.5', 'b=192.170.1.6']
end

docker_container 'echo-base' do
  repo 'alpine'
  tag '3.1'
  command 'nc -ll -p 1337 -e /bin/cat'
  port '1337'
  network_mode 'network_g'
  action :run
end
```

Connect to multiple networks

```ruby
docker_network 'network_h1' do
  action :create
end

docker_network 'network_h2' do
  action :create
end

docker_container 'echo-base-networks_h' do
  repo 'alpine'
  tag '3.1'
  command 'nc -ll -p 1337 -e /bin/cat'
  port '1337'
  network_mode 'network_h1'
  action :run
end

docker_network 'network_h2' do
  container 'echo-base-networks_h'
  action :connect
end
```

IPv6 enabled network

```ruby
docker_network 'network_i1' do
  enable_ipv6 true
  subnet 'fd00:dead:beef::/48'
  action :create
end
```
