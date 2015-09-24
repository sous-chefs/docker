Docker Cookbook
===============
[![Build Status](https://secure.travis-ci.org/bflad/chef-docker.png?branch=master)](http://travis-ci.org/bflad/chef-docker)
[![Gitter](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/bflad/chef-docker?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

The Docker Cookbook is a library cookbook that provides resources
(LWRPs) for use in recipes.

Scope
-----
This cookbook is concerned with the [Docker](http://docker.io)
container engine as distributed by Docker, Inc. It does not address
Docker ecosystem tooling or prerequisite technology such as cgroups or
aufs.

Requirements
------------
- Chef 12.4 or higher
- Ruby 2.1 or higher (preferably, the Chef full-stack installer)
- Network accessible web server hosting the docker binary.
- SELinux permissive/disabled if CentOS [Docker Issue #15498](https://github.com/docker/docker/issues/15498)


Platform Support
----------------
The following platforms have been tested with Test Kitchen: You may be
able to get it working on other platforms, with appropriate
configuration of cgroups and storage back ends.

```
|--------------+-------+-------+-------|
|              | 1.6.2 | 1.7.1 | 1.8.2 |
|--------------+-------+-------+-------|
| debian-8     | X     | X     | X     |
|--------------+-------+-------+-------|
| centos-7     | X     | X     | X     |
|--------------+-------+-------+-------|
| fedora-21    | X     | X     | X     |
|--------------+-------+-------+-------|
| ubuntu-12.04 | X     | X     | X     |
|--------------+-------+-------+-------|
| ubuntu-14.04 | X     | X     | X     |
|--------------+-------+-------+-------|
| ubuntu-15.04 | X     | X     | X     |
|--------------+-------+-------+-------|
```

Cookbook Dependencies
---------------------
- none!

Usage
-----
- Add ```depends 'docker', '~> 1.0'``` to your cookbook's metadata.rb
- Use resources shipped in cookbook in a recipe, the same way you'd
  use core Chef resources (file, template, directory, package, etc).

```ruby
docker_service 'default' do
  action [:create, :start]
end

docker_image 'busybox' do
  action :pull
end

docker_container 'an echo server' do
  repo 'busybox'
  port '1234:1234'
  command "nc -ll -p 1234 -e /bin/cat"
end
```

Test Cookbooks as Examples
--------------------------
The cookbooks ran under test-kitchen make excellent usage examples.

The test recipes are found at:
```ruby
test/cookbooks/docker_test/
test/cookbooks/docker_service_test/
```

Cgroups, Execution and Storage drivers
--------------------------------------
Beginning in chef-docker 1.0, support for LXC execution driver has
been removed in favor of native. Cgroups and storage drivers are now
loosely coupled dependencies and should be configured using other
cookbooks if needed.

Storage drivers can be selected with the `storage_driver` property on
the `docker_service` resource like this:

```ruby
docker_service 'default' do
   storage_driver 'overlay'
end
```

Configuration of the backing storage driver, including kernel module
loading, is out of scope for this cookbook.

Resources Overview
------------------
* `docker_service`: docker daemon installation and configuration
* `docker_image`: image/repository operations
* `docker_tag`: image tagging operations
* `docker_container`: container operations
* `docker_registry`: registry operations

## Getting Started
Here's a quick example of pulling the latest image and running a
container with exposed ports.

```ruby
# Pull latest image
docker_image 'nginx' do
  tag 'latest'
  action :pull
  notifies :redeploy, 'docker_container[my_nginx]'
end

# Run container exposing ports
docker_container 'my_nginx' do
  repo 'nginx'
  tag 'latest'
  port '80:80'
  hostname 'www'
  domain_name 'computers.biz'
  env 'FOO=bar'
  binds [ '/some/local/files/:/etc/nginx/conf.d' ]
end
```

You might run a private registry

```ruby
# Login to private registry
docker_registry 'https://registry.computers.biz/' do
  username 'shipper'
  password 'iloveshipping'
  email 'shipper@computers.biz'
end

# Pull tagged image
docker_image 'registry.computers.biz:443/my_project/my_container' do
  tag 'latest'
  action :pull
end

# Run container
docker_container 'crowsnest' do
  repo 'registry.computers.biz:443/my_project/my_container'
  tag 'latest'
  action :run
end
```

See full documentation for each resource and action below for more
information.

Resources Details
------------------
The ```docker_service```, ```docker_image```, ```docker_container```,
and ```docker_registry``` resources are documented in full below.

## docker_service
The `docker_service` manages a Docker daemon.

The `:create` action manages software installation.
The `:start` action manages the running docker service on the machine.

The service management strategy for the host platform is dynamically
chosen based on platform, but can be overridden. See the "providers"
section below for more information.

#### Example
```ruby
docker_service 'tls_test:2376' do
  host ["tcp://#{node['ipaddress']}:2376", 'unix:///var/run/docker.sock']
  tlscacert '/path/to/ca.pem'
  tlscert '/path/to/server.pem'
  tlskey '/path/to/serverkey.pem'
  tlsverify true
  provider Chef::Provider::DockerService::Systemd
  action [:create, :start]
end
```

WARNING - As of the 1.0 version of this cookbook, `docker_service`
is a singleton resource. This means that if you create multiple
`docker_service` resources on the same machine, you will only
create one actual service and things may not work as expected.

#### Properties
The `docker_service` resource property list mostly corresponds to
the options found in the
[Docker Command Line Reference](https://docs.docker.com/reference/commandline/cli/)

- `source` - URL to the pre-compiled Docker binary used for
  installation. Defaults to a calculated URL based on kernel version,
  Docker version, and platform arch. By default, this will try to get
  to "http://get.docker.io/builds/".
- `version` - Docker version to install
- `checksum` - sha256 checksum of Docker binary
- `instance` - Identity for ```docker_service``` resource. Defaults to
  name. Mostly unimportant for the 1.0 version because of its
  singleton status. | String | nil
- `api_cors_header` - Set CORS headers in the remote API
- `bridge` - Attach containers to a network bridge
- `bip` - Specify network bridge IP
- `debug` - Enable debug mode
- `daemon` - Enable daemon mode
- `dns` - DNS server(s) to use
- `dns_search` - DNS search domains to use
- `exec_driver` - Exec driver to use
- `fixed_cidr` - IPv4 subnet for fixed IPs
- `fixed_cidr_v6` - IPv6 subnet for fixed IPs
- `group` - Posix group for the unix socket
- `graph` - Root of the Docker runtime - Effectively, the "data directory"
- `host` - Daemon socket(s) to connect to - `tcp://host:port`,
  `unix:///path/to/socket`, `fd://*` or `fd://socketfd`
- `icc` - Enable inter-container communication
- `ip` - Default IP when binding container ports
- `ip_forward` - Enable ip forwarding
- `ipv4_forward` - Enable net.ipv4.ip_forward
- `ipv6_forward` - Enable net.ipv6.ip_forward
- `ip_masq` - Enable IP masquerading
- `iptables` - Enable addition of iptables rules
- `ipv6` - Enable IPv6 networking
- `log_level` - Set the logging level
- `label` - Set key=value labels to the daemon
- `log_driver` - Container's logging driver (json-file/syslog/journald/gelf/fluentd/none)
- `log_opts` - Container's logging driver options (driver-specific)
- `mtu` - Set the containers network MTU
- `pidfile` - Path to use for daemon PID file
- `registry_mirror` - Preferred Docker registry mirror
- `storage_driver` - Storage driver to use
- `selinux_enabled` - Enable selinux support
- `storage_opt` - Set storage driver options
- `tls` - Use TLS; implied by --tlsverify
- `tlscacert` - Trust certs signed only by this CA
- `tlscert` - Path to TLS certificate file
- `tlskey` - Path to TLS key file
- `tlsverify` - Use TLS and verify the remote
- `default_ulimit` - Set default ulimit settings for containers
- `http_proxy` - ENV variable set before for Docker daemon starts
- `https_proxy` - ENV variable set before for Docker daemon starts
- `no_proxy` - ENV variable set before for Docker daemon starts
- `tmpdir` - ENV variable set before for Docker daemon starts
- `logfile` - Location of Docker daemon log file
- `userland_proxy`- Enables or disables docker-proxy

#### Actions
- `:create` - Lays the Docker bits out on disk
- `:delete` - Removes the Docker bits from the disk
- `:start` - Makes sure the service provider is set up properly and start it
- `:stop` - Stops the service
- `:restart` - Restarts the service

#### Providers
- `Chef::Provider::DockerService::Execute` - The simplest provider. Just
  starts a process. Fire and forget.

- `Chef::Provider::DockerService::Sysvinit` - Uses a SystemV init script
  to manage the service state.

- `Chef::Provider::DockerService::Upstart` - Uses an Upstart script to
  manage the service state.

- `Chef::Provider::DockerService::Systemd` - Uses an Systemd unit file to
  manage the service state. NOTE: This does NOT enable systemd socket
  activation.

## docker_image
The `docker_image` is responsible for managing Docker image pulls,
builds, and deletions. It speaks directly to the
[Docker remote API](https://docs.docker.com/reference/api/docker_remote_api_v1.20/).

#### Examples

default action, default properties
```ruby
docker_image 'hello-world'
```

non-default name attribute
```ruby
docker_image "Tom's container" do
  repo 'tduffield/testcontainerd'
  action :pull
end
```

pull every time
```ruby
docker_image 'busybox' do
  action :pull
end
```

specify a tag
```ruby
docker_image 'alpine' do
  tag '3.1'
end
```

specify read/write timeouts
```ruby
docker_image 'alpine' do
  read_timeout 60
  write_timeout 60
end
```

```ruby
docker_image 'vbatts/slackware' do
  action :remove
end
```

save
```ruby
docker_image 'save hello-world' do
  repo 'hello-world'
  destination '/tmp/hello-world.tar'
  not_if { ::File.exist? '/tmp/hello-world.tar' }
  action :save
end
```

build from a Dockerfile on every chef-client run
```ruby
docker_image 'image_1' do
  tag 'v0.1.0'
  source '/src/myproject/container1/Dockerfile'
  action :build
end
```

build from a directory, only if image is missing
```ruby
docker_image 'image_2' do
  tag 'v0.1.0'
  source '/src/myproject/container2'
  action :build_if_missing
end
```

build from a tarball
NOTE: this is not an "export" tarball generated from an an image save.
The contents should be a Dockerfile, and anything it references to
COPY or ADD

```ruby
docker_image 'image_3' do
  tag 'v0.1.0'
  source '/tmp/image_3.tar'
  action :build
end
```

```ruby
docker_image 'hello-again' do
  tag 'v0.1.0'
  source '/tmp/hello-world.tar'
  action :import
end
```

push
```ruby
docker_image 'my.computers.biz:5043/someara/hello-again' do
  action :push
end
```

#### Properties
The `docker_image` resource properties mostly corresponds to the
[Docker Remote API](https://docs.docker.com/reference/api/docker_remote_api_v1.20/#2-2-images)
as driven by the
[Swipley docker-api Ruby gem](https://github.com/swipely/docker-api)

A `docker_image`'s full identifier is a string in the form
"\<repo\>:\<tag\>". There is some nuance around the naming when the public
registry vs a private one.

- `repo` - aka `image_name` - The first half of a Docker image's
  identity. This is a string in the form:
  `registry:port/owner/image_name`. If the `registry:port` portion is
  left off, Docker will implicitly use the Docker public registry.
  "Official Images" omit the owner part. This means a repo id can look
  as short as `busybox`, `alpine`, or `centos`, to refer to official
  images on the public registry, and as long as
  `my.computers.biz:5043:/what/ever` to refer to custom images on an
  private registry. Often you'll see something like `someara/chef` to
  refer to private images on the public registry. - Defaults to
  resource name.
- `tag` - The second half of a Docker image's identity. - Defaults to `latest`
- `source` - Path to input for the `:import`, `:build` and `:build_if_missing`
  actions. For building, this can be a Dockerfile, a tarball
  containing a Dockerfile in its root, or a directory containing a
  Dockerfile. For import, this should be a tarball containing Docker
  formatted image, as generated with `:save`.
- `destination` - Path for output from the `:save` action.
- `force` - A force boolean used in various actions - Defaults to false
- `nocache` - Used in `:build` operations. - Defaults to false
- `noprune` - Used in `:remove` operations - Defaults to false
- `rm` - Remove intermediate containers after a successful build
  (default behavior) - Defaults to `true`
- `read_timeout` - May need to increase for long image builds/pulls
- `write_timeout` - May need to increase for long image builds/pulls

#### Actions
The following actions are available for a `docker_image` resource.
Defaults to `pull_if_missing`

- `:pull` - Pulls an image from the registry
- `:pull_if_missing` - Pulls an image from the registry, only if it missing
- `:build` - Builds an image from a Dockerfile, directory, or tarball
- `:build_if_missing` - Same build, but only if it is missing
- `:save` - Exports an image to a tarball at `destination`
- `:import` - Imports an image from a tarball at `destination`
- `:remove` - Removes (untags) an image
- `:push` - Pushes an image to the registry

## docker_tag
Docker tags work very much like hard links in a Unix filesystem. They
are just references to an existing image. Therefore, the docker_tag
resource has taken inspiration from the Chef `link` resource.

#### Examples
```ruby
docker_tag 'private repo tag for hello-again:1.0.1' do
  target_repo 'hello-again'
  target_tag 'v0.1.0'
  to_repo 'localhost:5043/someara/hello-again'
  to_tag 'latest'
  action :tag
end
```

#### Properties
- `target_repo` - The repo half of the source image identifier.
- `target_tag` - The tag half of the source image identifier.
- `to_repo` - The repo half of the new image identifier
- `to_tag`- The tag half of the new image identifier

#### Actions
- `:tag` - Tags the image

## docker_container
The `docker_container` is responsible for managing Docker container
actions. It speaks directly to the [Docker remote API](https://docs.docker.com/reference/api/docker_remote_api_v1.20/).

Containers are process oriented, and move through an event cycle.
Thanks to [Glider Labs](http://gliderlabs.com/) for this excellent diagram.
![alt tag](http://gliderlabs.com/images/docker_events.png)

#### Examples

Create a container without starting it.

```ruby
docker_container 'hello-world' do
  command '/hello'
  action :create
end
```

This command will exit succesfully. This will happen on every
chef-client run.

```ruby
docker_container 'busybox_ls' do
  repo 'busybox'
  command 'ls -la /'
  action :run
end
```

The :run_if_missing action will only run once. It is the default action.

```ruby
docker_container 'alpine_ls' do
  repo 'alpine'
  tag '3.1'
  command 'ls -la /'
  action :run_if_missing
end
```

Set environment variables in a container

```ruby
docker_container 'env' do
  repo 'debian'
  env ['PATH=/usr/bin', 'FOO=bar']
  command 'env'
  action :run_if_missing
end
```

This process remains running between chef-client runs, :run will do nothing on subsequent converges.

```ruby
docker_container 'an_echo_server' do
  repo 'alpine'
  tag '3.1'
  command 'nc -ll -p 7 -e /bin/cat'
  port '7:7'
  action :run
end
```

Let docker pick the host port

```ruby
docker_container 'another_echo_server' do
  repo 'alpine'
  tag '3.1'
  command 'nc -ll -p 7 -e /bin/cat'
  port '7'
  action :run
end
```

Specify the udp protocol

```ruby
docker_container 'an_udp_echo_server' do
  repo 'alpine'
  tag '3.1'
  command 'nc -ul -p 7 -e /bin/cat'
  port '5007:7/udp'
  action :run
end
```

Kill a container

```ruby
docker_container 'bill' do
  action :kill
end
```

Stop a container

```ruby
docker_container 'hammer_time' do
  action :stop
end
```

Pause a container

```ruby
docker_container 'red_light' do
  action :pause
end
```

Unpause a container

```ruby
docker_container 'green_light' do
  action :unpause
end
```

Restart a container

```ruby
docker_container 'restarter' do
  action :restart
end
```

Delete a container

```ruby
docker_container 'deleteme' do
  remove_volumes true
  action :delete
end
```

Redeploy a container

```ruby
docker_container 'redeployer' do
  repo 'alpine'
  tag '3.1'
  command 'nc -ll -p 7777 -e /bin/cat'
  port '7'
  action :run
end

execute 'redeploy redeployer' do
  notifies :redeploy, 'docker_container[redeployer]', :immediately
  action :run
end
```

Bind mount local directories

```ruby
docker_container 'bind_mounter' do
  repo 'busybox'
  command 'ls -la /bits /more-bits'
  binds ['/hostbits:/bits', '/more-hostbits:/more-bits']
  action :run_if_missing
end
```

Mount volumes from another container

```ruby
docker_container 'chef_container' do
  command 'true'
  volumes '/opt/chef'
  action :create
end

docker_container 'ohai_debian' do
  command '/opt/chef/embedded/bin/ohai platform'
  repo 'debian'
  volumes_from 'chef_container'
end
```

Set a container's entrypoint

```ruby
docker_container 'ohai_again_debian' do
  repo 'debian'
  volumes_from 'chef_container'
  entrypoint '/opt/chef/embedded/bin/ohai'
  command 'platform'
  action :run_if_missing
end
```

Automatically remove a container after it exits

```ruby
docker_container 'sean_was_here' do
  command "touch /opt/chef/sean_was_here-#{Time.new.strftime('%Y%m%d%H%M')}"
  repo 'debian'
  volumes_from 'chef_container'
  autoremove true
  action :run
end
```

Grant NET_ADMIN rights to a container

```ruby
docker_container 'cap_add_net_admin' do
  repo 'debian'
  command 'bash -c "ip addr add 10.9.8.7/24 brd + dev eth0 label eth0:0 ; ip addr list"'
  cap_add 'NET_ADMIN'
  action :run_if_missing
end
```

Revoke MKNOD rights to a container
```ruby
docker_container 'cap_drop_mknod' do
  repo 'debian'
  command 'bash -c "mknod -m 444 /dev/urandom2 c 1 9 ; ls -la /dev/urandom2"'
  cap_drop 'MKNOD'
  action :run_if_missing
end
```

Set a container's hostname and domainname

```ruby
docker_container 'fqdn' do
  repo 'debian'
  command 'hostname -f'
  host_name 'computers'
  domain_name 'biz'
  action :run_if_missing
end
```

Set a container's DNS resolution

```ruby
docker_container 'dns' do
  repo 'debian'
  command 'cat /etc/resolv.conf'
  host_name 'computers'
  dns ['4.3.2.1', '1.2.3.4']
  dns_search ['computers.biz', 'chef.io']
  action :run_if_missing
end
```

Add extra hosts to a container's `/etc/hosts`

```ruby
docker_container 'extra_hosts' do
  repo 'debian'
  command 'cat /etc/hosts'
  extra_hosts ['east:4.3.2.1', 'west:1.2.3.4']
  action :run_if_missing
end
```

Manage container's restart_policy

```ruby
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
```

Manage container links

```ruby
docker_container 'link_source' do
  repo 'alpine'
  tag '3.1'
  env ['FOO=bar', 'BIZ=baz']
  command 'nc -ll -p 321 -e /bin/cat'
  port '321'
  action :run_if_missing
end

docker_container 'link_target_1' do
  repo 'alpine'
  tag '3.1'
  env ['ASD=asd']
  command 'ping -c 1 hello'
  links ['link_source:hello']
  action :run_if_missing
end

docker_container 'link_target_2' do
  repo 'alpine'
  tag '3.1'
  command 'env'
  links ['link_source:hello']
  action :run_if_missing
end

execute 'redeploy_link_source' do
  command 'touch /marker_container_redeploy_link_source'
  creates '/marker_container_redeploy_link_source'
  notifies :redeploy, 'docker_container[link_source]', :immediately
  notifies :redeploy, 'docker_container[link_target_1]', :immediately
  notifies :redeploy, 'docker_container[link_target_2]', :immediately
  action :run
end
```

Mutate a container between chef-client runs

```ruby
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
  command 'true'
  notifies :commit, 'docker_container[mutator]', :immediately
  notifies :export, 'docker_container[mutator]', :immediately
  notifies :redeploy, 'docker_container[mutator]', :immediately
  action :run
end
```

Specify read/write timeouts

```ruby
docker_container 'api_timeouts' do
  repo 'alpine'
  read_timeout 60
  write_timeout 60
end
```

Specify a custom logging driver and its options

```ruby
docker_container 'syslogger' do
  repo 'alpine'
  tag '3.1'
  command 'nc -ll -p 780 -e /bin/cat'
  log_driver 'syslog'
  log_opts 'syslog-tag=container-syslogger'
end
```

#### Properties

Most `docker_container` properties are the `snake_case` version of the
`CamelCase` keys found in the
[Docker Remote Api](https://docs.docker.com/reference/api/docker_remote_api_v1.20/)

- `container_name` - The name of the container. Defaults to the name
  of the `docker_container` resource.
- `repo` - aka `image_name`. The first half of a the complete
  identifier for a Docker Image.
- `tag` - The second half of a Docker image's identity. - Defaults to
  `latest`.
- `command` - The command to run when starting the container.
- `autoremove` - Boolean - Automatically delete a container when it's
  command exits. Defaults to `false`.
- `binds` - An array of `:` separated paths to bind mount from the
  host into the container in the form
  `['/host-bits:/container-bits', '/more-host-bits:/more-container-bits']`.
  Defaults to `nil`.
- `cap_add` - An array Linux Capabilities (`man 7 capabilities`) to
  add to grant the container beyond what it normally gets.
- `cap_drop` - An array Linux Capabilities (`man 7 capabilities`) to
  revoke that the container normally has.
- `cpu_shares` - An integer value containing the CPU Shares for the
  container.
- `devices` - A Hash of devices to add to the container.
- `dns` - An array of DNS servers the container will use for name
  resolution.
- `dns_search` - An array of domains the container will search for
  name resolution.
- `domain_name` - Set's the container's dnsdomainname as returned by
  the `dnsdomainname` command.
- `entry_point` - Set the entry point for the container as a string or
  an array of strings.
- `env` - Set environment variables in the container in the form
  `['FOO=bar', 'BIZ=baz']`
- `extra_hosts` - An array of hosts to add to the container's
  `/etc/hosts` in the form `['host_a:10.9.8.7', 'host_b:10.9.8.6']`
- `force` - A boolean to use in container operations that support a
  `force` option. Defaults to `false`
- `host_name` - The hostname for the container.
- `links` - An array of source container/alias pairs to link the
  container to in the form `[container_a:www', container_b:db']`
- `log_driver` - Sets a custom logging driver for the container
  (json-file/syslog/journald/gelf/fluentd/none).
- `log_opts` - Configures the above logging driver options (driver-specific).
- `mac_address` - The mac address for the container to use.
- `memory` - Memory limit in bytes.
- `memory_swap` - Total memory limit (memory + swap); set `-1` to
  disable swap. You must use this with memory and make the swap value
  larger than memory.
- `network_disabled` - Boolean to disable networking. Defaults to `false`.
- `network_mode` - Sets the networking mode for the container.
- `open_stdin` - Boolean value, opens stdin. Defaults to `false`.
- `outfile` - The path to write the file when using `:export` action.
- `port` - The port configuration to use in the container. Matches the
  syntax used by the `docker` CLI tool.
- `privileged` - Boolean to start the container in privileged more.
  Defaults to `false`
- `publish_all_ports` - Allocates a random host port for all of a
  container’s exposed ports.
- `remove_volumes` - A boolean to clean up "dangling" volumes when
  removing the last container with a reference to it. Default to
  `false` to match the Docker CLI behavior.
- `restart_policy` - One of `no`, `on-failure`, or `always`. Use
  `always` if you want a service container to survive a Dockerhost
  reboot. Defaults to `no`.
- `restart_maximum_retry_count` - Maximum number of restarts to try
  when `restart_policy` is `on-failure`. Defaults to an ever
  increasing delay (double the previous delay, starting at 100mS), to
  prevent flooding the server.
- `security_opts` - A list of string values to customize labels for
  MLS systems, such as SELinux.
- `signal` - The signal to send when using the `:kill` action.
  Defaults to `SIGKILL`.
- `tty` - Boolean value to allocate a pseudo-TTY. Defaults to `false`.
- `user` - A string value specifying the user inside the container.
- `volumes` - An Array of paths inside the container to expose. Does
  the same thing as the `VOLUME` directive in a Dockerfile, but works
  on container creation.
- `volumes_from` - A list of volumes to inherit from another
  container. Specified in the form `<container name>[:<ro|rw>]`
- `working_dir` - A string specifying the working directory for
  commands to run in.
- `read_timeout` - May need to increase for commits or exports that are slow
- `write_timeout` - May need to increase for commits or exports that are slow

#### Actions

- `:create` - Creates the container but does not start it. Useful for
  Volume containers.
- `:start` - Starts the container. Useful for containers that run
  jobs.. command that exit.
- `:run` - Both `:create` and `:start` the container in one action.
- `:run_if_missing` - The default action. Runs a container only once.
- `:stop` - Stops the container.
- `:restart` - Stops the starts the container.
- `:kill` - Send a signal to the container process. Defaults to `SIGKILL`.
- `:pause` - Pauses the container.
- `:unpause` - Unpauses the container.
- `:delete` - Deletes the container.
- `:redeploy` - Deletes and runs the container.

## docker_registry

The `docker_registry` resource is responsible for managing the
connection auth information to a Docker registry.

#### docker_registry action :login

Log into or register with public registry:

```ruby
docker_registry 'https://index.docker.io/v1/' do
  username 'publicme'
  password 'hope_this_is_in_encrypted_databag'
  email 'publicme@computers.biz'
end
```

Log into private registry with optional port:

```ruby
docker_registry 'my local registry' do
   serveraddress 'https://registry.computers.biz:8443/'
   username 'privateme'
   password 'still_hope_this_is_in_encrypted_databag'
   email privateme@computers.biz'
end
```

## Testing and Development

* Full development and testing workflow with Test Kitchen and friends: [TESTING.md](TESTING.md)

## Contributing

Please see contributing information in: [CONTRIBUTING.md](CONTRIBUTING.md)

## Maintainers

* Tom Duffield (http://tomduffield.com)
* Brian Flad (<bflad417@gmail.com>)
* Fletcher Nichol (<fnichol@nichol.ca>)
* Sean OMeara (<sean@chef.io>)

## License
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
