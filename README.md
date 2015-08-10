Docker Cookbook
===============
[![Build Status](https://secure.travis-ci.org/bflad/chef-docker.png?branch=master)](http://travis-ci.org/bflad/chef-docker)
[![Gitter](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/bflad/chef-docker?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

The Docker Cookbook is a library cookbook that provides resources
(LWRPs) for use in recipes.

Breaking Changes Alert - UNSTABLE until 1.0.0
----------------------
For version 1.0 of this cookbook (work in progress), we have made (are making) significant
breaking changes including the way that we handle resources
(`docker_image`, `docker_container` and `docker_registry`). It is
highly recommended that you constrain the version of the cookbook you
are using in the appropriate places.

- metadata.rb
- Chef Environments
- Berksfile
- Chef Policyfile

Scope
-----
This cookbook is concerned with the [Docker](http://docker.io)
container engine as distributed by Docker, Inc. It does not address
with docker ecosystem tooling or prerequisite technology such as
cgroups or aufs.

Requirements
------------
- Chef 11 or higher
- Ruby 1.9 or higher (preferably from the Chef full-stack installer)
- Network accessible web server hosting the docker binary.

Platform Support
----------------
The following platforms have been tested with Test Kitchen:

```
|--------------+-------|
|              | 1.6.0 |
|--------------+-------|
| amazon       | X     |
|--------------+-------|
| centos-6     | X     |
|--------------+-------|
| centos-7     | X     |
|--------------+-------|
| fedora-21    | X     |
|--------------+-------|
| debian-7     | X     |
|--------------+-------|
| ubuntu-12.04 | X     |
|--------------+-------|
| ubuntu-14.04 | X     |
|--------------+-------|
| ubuntu-15.04 | X     |
|--------------+-------|
```

Cookbook Dependencies
---------------------
- none!

Usage
-----
- Add ```depends 'docker', '~> 1.0'``` to your cookbook's metadata.rb
- Place resources shipped in this cookbook in a recipe, the same way
  you'd use core Chef resources (file, template, directory, package, etc).

```ruby
docker_service 'default' do
  action [:create, :start]
end

docker_image 'busybox' do
  action :pull
end

docker_container 'an echo server' do
  repo 'busybox'
  tag 'latest'
  port '1234:1234'
  command "nc -ll -p 1234 -e /bin/cat"
end
```

Test Cookbooks as Examples
--------------------------
The cookbooks ran under test-kitchen make excellent usage examples.
The above recipe is actually used as a smoke test, and is converged by
test-kitchen during development. It is located in this repo at
`test/cookbooks/docker_test/recipes/hello_world.rb`

More example recipes can be found at:
```ruby
test/cookbooks/docker_test/
test/cookbooks/docker_service_test/
```

Cgroups, Execution and Storage drivers
--------------------------------------
Beginning in chef-docker 1.0, support for LXC execution driver has
been removed in favor of native. Cgroups and storage drivers are now
loosely coupled dependencies and should be configured using other
cookbooks.

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
* `docker_registry`: registry operations
* `docker_container`: container operations

## Getting Started
Here's a quick example of pulling the latest image and running a
container with exposed ports (creates service automatically):

```ruby
# Pull latest image
docker_image 'nginx' do
  tag '1.9'
  action :pull_if_missing
end

# Run container exposing ports
docker_container 'my_nginx' do
  repo 'nginx'
  tag '1.9'
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
- `dns` - DNS server to use
- `dns_search` - DNS search domains to use
- `exec_driver` - Exec driver to use
- `fixed_cidr` - IPv4 subnet for fixed IPs
- `fixed_cidr_v6` - IPv6 subnet for fixed IPs
- `group` - Posix group for the unix socket
- `graph` - Root of the Docker runtime - Effectively, the "data directory"
- `host` - Daemon socket(s) to connect to - `tcp://host:port`,
  `unix:///path/to/socket`, `fd://*` or `fd://socketfd`
- `icc` - Enable inter-container communication
- `ip` - Enable inter-container communication
- `ip_forward` - Enable ip forwarding
- `ipv4_forward` - Enable net.ipv4.ip_forward
- `ipv6_forward` - Enable net.ipv6.ip_forward
- `ip_masq` - Enable IP masquerading
- `iptables` - Enable addition of iptables rules
- `ipv6` - Enable IPv6 networking
- `log_level` - Set the logging level
- `label` - Set key=value labels to the daemon
- `log_driver` - Container's logging driver (json-file/none)
- `mtu` - Container's logging driver (json-file/none)
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
[Docker remote API](https://docs.docker.com/reference/api/docker_remote_api_v1.16/).

#### Examples

#### default action, default properties
```ruby
docker_image 'hello-world'
```

#### non-default name attribute
```ruby
docker_image "Tom's container" do
  repo 'tduffield/testcontainerd'
  action :pull_if_missing
end
```

#### :pull every time
```ruby
docker_image 'busybox' do
  action :pull
end
```

#### specify a tag
```ruby
docker_image 'alpine' do
  tag '3.1'
end
```

```ruby
docker_image 'vbatts/slackware' do
  action :remove
end
```

#### :save
```ruby
docker_image 'save hello-world' do
  repo 'hello-world'
  destination '/tmp/hello-world.tar'
  not_if { ::File.exist? '/tmp/hello-world.tar' }
  action :save
end
```

#### :build from a Dockerfile on every chef-client run
```ruby
docker_image 'image_1' do
  tag 'v0.1.0'
  source '/src/myproject/container1/Dockerfile'
  action :build
end
```

#### :build from a directory, only if image is missing
```ruby
docker_image 'image_2' do
  tag 'v0.1.0'
  source '/src/myproject/container2'
  action :build_if_missing
end
```

#### :build from a tarball
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

#### :push
```ruby
docker_image 'my.computers.biz:5043/someara/hello-again' do
  action :push
end
```

#### Properties
The `docker_image` resource properties mostly corresponds to the
[Docker Remote API](https://docs.docker.com/reference/api/docker_remote_api_v1.16/#2-2-images)
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
- `force` A force boolean used in various actions - Defaults to false
- `nocache` - Used in `:build` operations. - Defaults to false
- `noprune` - Used in `:remove` operations - Defaults to false
- `rm` - Remove intermediate containers after a successful build
  (default behavior) - Defaults to `true`

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
actions. It speaks directly to the [Docker remote API](https://docs.docker.com/reference/api/docker_remote_api_v1.16/).

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

#### Properties

SAVEGAME: you are here

#### Actions

## docker_registry
FIXME: blah blah blah

#### docker_registry action :login

Log into or register with public registry:

```ruby
docker_registry 'https://index.docker.io/v1/' do
  email 'publicme@example.com'
  username 'publicme'
  password 'hope_this_is_in_encrypted_databag'
end
```

Log into private registry with optional port:

```ruby
docker_registry 'https://docker-registry.example.com:8443/' do
   username 'privateme'
   password 'still_hope_this_is_in_encrypted_databag'
end
```

## Testing and Development

* Quickly testing with Vagrant: [VAGRANT.md](VAGRANT.md)
* Full development and testing workflow with Test Kitchen and friends: [TESTING.md](TESTING.md)

## Contributing

Please see contributing information in: [CONTRIBUTING.md](CONTRIBUTING.md)

## Maintainers

* Tom Duffield (http://tomduffield.com)
* Brian Flad (<bflad417@gmail.com>)
* Fletcher Nichol (<fnichol@nichol.ca>)
* Sean OMeara (sean@chef.io)

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
