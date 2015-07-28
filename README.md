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

More details about specific changes will be documented in the
[1.0_CHANGES.md](1.0_CHANGES.md) file.

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
  image 'busybox'
  port '1234:1234'
  command "nc -ll -p 1234 -e /bin/cat"
  detach true
  init_type false
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

### Getting Started
Here's a quick example of pulling the latest image and running a
container with exposed ports (creates service automatically):

```ruby
# Pull latest image
docker_image 'samalba/docker-registry'

# Run container exposing ports
docker_container 'samalba/docker-registry' do
  detach true
  port '5000:5000'
  env 'SETTINGS_FLAVOR=local'
  volume '/mnt/docker:/docker-storage'
end
```

Maybe you want to automatically update your private registry with
changes from your container?

```ruby
# Login to private registry
docker_registry 'https://docker-registry.example.com/' do
  username 'shipper'
  password 'iloveshipping'
end

# Pull tagged image
docker_image 'apps/crowsnest' do
  tag 'not-latest'
end

# Run container
docker_container 'crowsnest' do
  action :run
end

# Save current timestamp
timestamp = Time.new.strftime('%Y%m%d%H%M')

# Commit container changes
docker_tag 'crowsnest current timestamp' do
   target_repo 'apps/crowsnest'
   target_tag 'not-latest'
   to_repo 'apps/crowsnest'
   to_tag timestamp
   action :tag
end

# Push image
docker_image 'apps/crowsnest' do
  tag timestamp
  action :push
end
```

See full documentation for each resource and action below for more
information.

Resources Details
------------------
The ```docker_service```, ```docker_image```, ```docker_container```,
and ```docker_registry``` resources are documented in full below.

### docker_service
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
- `graph` - Root of the Docker runtime - Effectively, the "data
  directory"
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
- http_proxy - ENV variable set before for Docker daemon starts
- https_proxy - ENV variable set before for Docker daemon starts
- no_proxy - ENV variable set before for Docker daemon starts
- tmpdir - ENV variable set before for Docker daemon starts
- logfile - Location of Docker daemon log file

#### Actions
- `:create` - Lays the Docker bits out on disk
- `:delete` - Removes the Docker bits from the disk
- `:start` - Makes sure the service provider is set up properly and start it
- `:stop` - Stops the service
- `:restart` - Restarts the service

#### Providers
- Chef::Provider::DockerService::Execute - The simplest provider. Just
  starts a process. Fire and forget.

- Chef::Provider::DockerService::Sysvinit - Uses a SystemV init script
  to manage the service state.

- Chef::Provider::DockerService::Upstart - Uses an Upstart script to
  manage the service state.

- Chef::Provider::DockerService::Systemd - Uses an Systemd unit file to
  manage the service state. NOTE: This does NOT enable systemd socket
  activation.

### docker_image

#### Examples

# default action, default properties
docker_image 'hello-world'

# non-default name attribute
docker_image "Tom's container" do
  repo 'tduffield/testcontainerd'
  action :pull_if_missing
end

# :pull every time
docker_image 'busybox' do
  action :pull
end

# specify a tag
docker_image 'alpine' do
  tag '3.1'
end

docker_image 'vbatts/slackware' do
  action :remove
end

# :save
docker_image 'save hello-world' do
  repo 'hello-world'
  destination '/tmp/hello-world.tar'
  not_if { ::File.exist? '/tmp/hello-world.tar' }
  action :save
end

# :build from a Dockerfile on every chef-client run
docker_image 'image_1' do
  tag 'v0.1.0'
  source '/src/myproject/container1/Dockerfile'
  action :build
end

# :build from a directory, only if image is missing
docker_image 'image_2' do
  tag 'v0.1.0'
  source '/src/myproject/container2'
  action :build_if_missing
end

# :build from a tarball
#
# NOTE: this is not an "export" tarball generated from an an image
# save.
#
# The contents should be a Dockerfile, and anything it references to
# COPY or ADD
docker_image 'image_3' do
  tag 'v0.1.0'
  source '/tmp/image_3.tar'
  action :build
end

docker_image 'hello-again' do
  tag 'v0.1.0'
  source '/tmp/hello-world.tar'
  action :import
end

# :push
docker_image 'my.computers.biz:5043/someara/hello-again' do
  action :push
end

#### Properties
The `docker_image` resource properties mostly corresponds to the
[Docker Remote API](https://docs.docker.com/reference/api/docker_remote_api_v1.16/#2-2-images)
as driven by the
[Swipley docker-api Ruby gem](https://github.com/swipely/docker-api)

A `docker_image`'s full identifier is a string in the form
"<repo>:<tag>". There is some nuance around the naming when the public
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

### docker_tag
Docker tags work very much like hard links in a Unix filesystem. They
are just references to an existing image. Therefore, the docker_tag
resource has taken inspiration from the Chef `link` resource.

#### Examples
docker_tag 'private repo tag for hello-again:1.0.1' do
  target_repo 'hello-again'
  target_tag 'v0.1.0'
  to_repo 'localhost:5043/someara/hello-again'
  to_tag 'latest'
  action :tag
end

#### Properties
- `target_repo` - The repo half of the source image identifier.
- `target_tag` - The tag half of the source image identifier.
- `to_repo` - The repo half of the new image identifier
- `to_tag`- The tag half of the new image identifier

#### Actions
- `:tag` - Tags the image

### SAVEGAME: you are here
### docker_container

Below are the available actions for the LWRP, default being `run`.

These attributes are associated with all LWRP actions.

Property | Description | Type | Default
---------|-------------|------|---------
cmd_timeout | Timeout for docker commands (catchable exception: `Chef::Provider::Docker::Container::CommandTimeout`) | Integer | 60
command | Command to run in or identify container | String  | nil
container_name | Name for container/service | String | nil

#### docker_container action :commit

These attributes are associated with this LWRP action.

Attribute | Description | Type | Default
----------|-------------|------|--------
author | Author for commit | String | nil
message | Message for commit | String | nil
repository | Remote repository | String | nil
run | Configuration to be applied when the image is launched with `docker run` | String | nil
tag | Specific tag for image | String | nil

Commit a container with optional repository, run specification, and tag:

```ruby
docker_container 'myApp' do
repository 'myRepo'
tag Time.new.strftime("%Y%m%d%H%M")
run '{"Cmd": ["cat", "/world"], "PortSpecs": ["22"]}'
action :commit
end
```

#### docker_container action :cp

These attributes are associated with this LWRP action.

Attribute | Description | Type | Default
----------|-------------|------|--------
destination | Host path to copy file | String | nil
source | Container path to get file | String | nil

Copying a file from container to host:

```ruby
docker_container 'myApp' do
  source '/path/to/container/file'
  destination '/path/to/save/on/host'
  action :cp
end
```

#### docker_container action :create

By default, this will handle creating a service for the container when action is create, run or start. `set['docker']['container_init_type'] = false` or add `init_type false` for LWRP to disable this behavior.

Attributes for this action can be found in the `run` action (except for the `detach` attribute).

#### docker_container action :export

These attributes are associated with this LWRP action.

Attribute | Description | Type | Default
----------|-------------|------|--------
destination | Host path to save tarball | String | nil

Exporting container to host:

```ruby
docker_container 'myApp' do
  destination '/path/to/save/on/host.tgz'
  action :export
end
```

#### docker_container action :kill

These attributes are associated with this LWRP action.

Attribute | Description | Type | Default
----------|-------------|------|--------
cookbook | Cookbook to grab any templates | String | docker
init_type | Init type for container service handling | FalseClass, String | `node['docker']['container_init_type']`
init_template | Template to use for init configuration | String | nil
signal | Signal to send to the container | String | nil (implicitly KILL)
socket_template | Template to use for configuring socket (relevent for init_type systemd only) | String | nil

Kill a running container:

```ruby
docker_container 'shipyard' do
  action :kill
end
```

Send SIGQUIT to a running container:

```ruby
docker_container 'shipyard' do
  signal 'QUIT'
  action :kill
end
```

#### docker_container action :redeploy

Stops, removes, and runs a container. Useful for notifications from image build/pull.

Attributes for this action can be found in the `stop`, `remove`, and `run` actions.

Redeploy container when new image is pulled:

```ruby
docker_image 'shipyard/shipyard' do
  action :pull
  notifies :redeploy, 'docker_container[shipyard]', :immediately
end

docker_container 'shipyard' do
  # Other attributes
  action :run
end
```

#### docker_container action :remove

These attributes are associated with this LWRP action.

Attribute | Description | Type | Default
----------|-------------|------|--------
cookbook | Cookbook to grab any templates | String | docker
force | Force removal | TrueClass, FalseClass | nil
init_type | Init type for container service handling | FalseClass, String | `node['docker']['container_init_type']`
init_template | Template to use for init configuration | String | nil
socket_template | Template to use for configuring socket (relevent for init_type systemd only) | String | nil

Remove a container:

```ruby
docker_container 'shipyard' do
  action :remove
end
```

#### docker_container action :remove_link

These attributes are associated with this LWRP action.

Attribute | Description | Type | Default
----------|-------------|------|--------
link | Link to remove from container | String | nil

Remove a container:

```ruby
docker_container 'shipyard' do
  link 'foo'
  action :remove_link
end
```

#### docker_container action :remove_volume

These attributes are associated with this LWRP action.

Attribute | Description | Type | Default
----------|-------------|------|--------
volume | Volume(s) to remove from container | String, Array | nil

Remove a container:

```ruby
docker_container 'shipyard' do
  volume %w(/extravol1 /extravol2)
  action :remove_volume
end
```

#### docker_container action :restart

These attributes are associated with this LWRP action.

Attribute | Description | Type | Default
----------|-------------|------|--------
cookbook | Cookbook to grab any templates | String | docker
init_type | Init type for container service handling | FalseClass, String | `node['docker']['container_init_type']`
init_template | Template to use for init configuration | String | nil
socket_template | Template to use for configuring socket (relevent for init_type systemd only) | String | nil

Restart a container:

```ruby
docker_container 'shipyard' do
  action :restart
end
```

#### docker_container action :run

By default, this will handle creating a service for the container when action is create, run or start. `set['docker']['container_init_type'] = false` or add `init_type false` for LWRP to disable this behavior.

These attributes are associated with this LWRP action.

Attribute | Description | Type | Default
----------|-------------|------|--------
additional_host | Add a custom host-to-IP mapping (host:ip) | String, Array | nil
attach | Attach container's stdout/stderr and forward all signals to the process | TrueClass, FalseClass | nil
cap_add | Capabilities to add to container | String, Array | nil
cidfile | File to store container ID | String | nil
container_name | Name for container/service | String | nil
cookbook | Cookbook to grab any templates | String | docker
cpu_shares | CPU shares for container | Fixnum | nil
detach | Detach from container when starting | TrueClass, FalseClass | nil
device | Device(s) to pass through to container | String, Array | nil
dns | DNS servers for container | String, Array | nil
dns_search | DNS search domains for container | String, Array | nil
entrypoint | Overwrite the default entrypoint set by the image | String | nil
env | Environment variables to pass to container | String, Array | nil
env_file | Read in a line delimited file of ENV variables | String | nil
expose | Expose a port from the container without publishing it to your host | Fixnum, String, Array | nil
hostname | Container hostname | String | nil
image | Image for container | String | LWRP name
init_type | Init type for container service handling | FalseClass, String | `node['docker']['container_init_type']`
init_template | Template to use for init configuration | String | nil
link | Add link to another container | String, Array | nil
label | Options to pass to underlying labeling system | String | nil
lxc_conf | Custom LXC options | String, Array | nil
memory | Set memory limit for container | Fixnum, String | nil
net | [Configure networking](http://docs.docker.io/reference/run/#network-settings) for container | String | nil
networking (*DEPRECATED*) | Configure networking for container | TrueClass, FalseClass | true
opt | Custom driver options | String, Array | nil
port | Map network port(s) to the container | Fixnum (*DEPRECATED*), String, Array | nil
privileged | Give extended privileges | TrueClass, FalseClass | nil
public_port (*DEPRECATED*) | Map host port to container | Fixnum | nil
publish_exposed_ports | Publish all exposed ports to the host interfaces | TrueClass, FalseClass | false
remove_automatically | Automatically remove the container when it exits (incompatible with detach) | TrueClass, FalseClass | false
restart | Restart policy for the container (no, on-failure, always) | String | nil
socket_template | Template to use for configuring socket (relevent for init_type systemd only) | String | nil
stdin | Attach container's stdin | TrueClass, FalseClass | nil
tty | Allocate a pseudo-tty | TrueClass, FalseClass | nil
user | User to run container | String | nil
volume | Create bind mount(s) with: [host-dir]:[container-dir]:[rw\|ro]. If "container-dir" is missing, then docker creates a new volume. | String, Array | nil
volumes_from | Mount all volumes from the given container(s) | String | nil
working_directory | Working directory inside the container | String | nil

Run a container:

```ruby
docker_container 'myImage' do
  detach true
end
```

Run a container via command:

```ruby
docker_container 'busybox' do
  command 'sleep 9999'
  detach true
end
```

Run a container from image (docker-registry for example):

```ruby
docker_container 'docker-registry' do
  image 'samalba/docker-registry'
  detach true
  hostname 'docker-registry.example.com'
  port '5000:5000'
  env 'SETTINGS_FLAVOR=local'
  volume '/mnt/docker:/docker-storage'
end
```

Run a container form image with arguments (logspout for example):

```ruby
docker_container 'progrium/logspout syslog://logs.papertrailapp.com:999999' do
  action :run
  container_name 'logspout'
  detach true
  hostname node[:hostname]
  volume '/var/run/docker.sock:/tmp/docker.sock'
end
```

This would produce the command:

```
%> docker run \
    --name=logspout \
    -d \
    -h $(hostname) \
    -v=/var/run/docker.sock:/tmp/docker.sock \
    progrium/logspout syslog://logs.papertrailapp.com:999999`
```

#### docker_container action :start

These attributes are associated with this LWRP action.

Attribute | Description | Type | Default
----------|-------------|------|--------
attach | Attach container's stdout/stderr and forward all signals to the cookbook | Cookbook to grab any templates | String | docker
init_type | Init type for container service handling | FalseClass, String | `node['docker']['container_init_type']`
init_template | Template to use for init configuration | String | nil
socket_template | Template to use for configuring socket (relevent for init_type systemd only) | String | nil
stdin | Attach container's stdin | TrueClass, FalseClass | nil

Start a stopped container:

```ruby
docker_container 'shipyard' do
  action :start
end
```

#### docker_container action :stop

These attributes are associated with this LWRP action.

Attribute | Description | Type | Default
----------|-------------|------|--------
cookbook | Cookbook to grab any templates | String | docker
init_type | Init type for container service handling | FalseClass, String | `node['docker']['container_init_type']`
init_template | Template to use for init configuration | String | nil
socket_template | Template to use for configuring socket (relevent for init_type systemd only) | String | nil

Stop a running container:

```ruby
docker_container 'shipyard' do
  action :stop
end
```

#### docker_container action :wait

Wait for a container to finish:

```ruby
docker_container 'busybox' do
  command 'sleep 9999'
  action :wait
end
```

### docker_registry
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
