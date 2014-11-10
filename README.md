# chef-docker [![Build Status](https://secure.travis-ci.org/bflad/chef-docker.png?branch=master)](http://travis-ci.org/bflad/chef-docker)

## Description

Installs/Configures [Docker](http://docker.io). Please see [COMPATIBILITY.md](COMPATIBILITY.md) for more information about Docker versions that are tested and supported by cookbook versions along with LWRP features.

This cookbook was inspired by @thoward's docker-cookbook: https://github.com/thoward/docker-cookbook

## Breaking Change Alert

In version 1.0 of this cookbook, we will be making a significant breaking changes including the way that we handle the custom resources (`docker_image`, `docker_container` and `docker_registry`). It is highly recommended that you constrain the version of the cookbook you are using in the appropriate places.
  - metadata.rb
  - Chef Environments
  - Berksfile
  - Chef Policyfile

More details about specific changes will be documented in the [1.0_CHANGES.md](1.0_CHANGES.md) file. 

## Requirements

### Chef

* Chef 11+

### Platforms

* Amazon 2014.03.1 (experimental)
* CentOS 6
* Debian 7
* Fedora 19, 20
* Mac OS X (only docker installation currently)
* Oracle 6
* RHEL 6
* Ubuntu 12.04, 12.10, 13.04, 13.10, 14.04 (experimental)

### Cookbooks

[Opscode Cookbooks](https://github.com/opscode-cookbooks/)

* [apt](https://github.com/opscode-cookbooks/apt)
* [git](https://github.com/opscode-cookbooks/git)
* [homebrew](https://github.com/opscode-cookbooks/homebrew)
* [yum-epel](https://github.com/opscode-cookbooks/yum-epel)

Third-Party Cookbooks

* [aufs](https://github.com/bflad/chef-aufs)
* [device-mapper](https://github.com/bflad/chef-device-mapper)
* [golang](https://github.com/NOX73/chef-golang)
* [lxc](https://github.com/hw-cookbooks/lxc)
* [modules](https://github.com/Youscribe/modules-cookbook)
* [sysctl](https://github.com/onehealth-cookbooks/sysctl)

## Usage

### Default Installation

* Add `recipe[docker]` to your node's run list

### Execution Drivers

If your system is running a Docker version before 0.9, you'll need to explicitly set up LXC outside of this cookbook. This will likely be true for most distros after Docker 1.0 and chef-docker 1.0 is released.
* [lxc on community site](http://community.opscode.com/cookbooks/lxc)
* [lxc on Github](https://github.com/hw-cookbooks/lxc/)

### Storage Drivers

Beginning in chef-docker 1.0, storage driver installation and configuration is expected to be handled before this cookbook's execution, except where required by Docker.

#### AUFS

If you need AUFS support, consider adding the aufs cookbook to your node/recipe before docker.
* [aufs on community site](http://community.opscode.com/cookbooks/aufs)
* [chef-aufs on Github](https://github.com/bflad/chef-aufs)

Then, set the `storage_driver` attribute of this cookbook to `aufs`.

#### device-mapper

If you need device-mapper support, consider adding the device-mapper cookbook to your node/recipe before docker.
* [device-mapper on community site](http://community.opscode.com/cookbooks/device-mapper)
* [chef-device-mapper on Github](https://github.com/bflad/chef-device-mapper)

Then, set the `storage_driver` attribute of this cookbook to `devicemapper` (please note lack of dash).

### Ubuntu 14.04 Package Installation via Docker PPA

By default, this cookbook will use the docker.io package from Ubuntu 14.04's repository. To use the Docker PPA package, just set the repo_url attribute to the Docker PPA URL. e.g. `node.set['docker']['package']['repo_url'] = 'https://get.docker.io/ubuntu'`

## Attributes

### Installation/System Attributes

These attributes are under the `node['docker']` namespace.

Attribute | Description | Type | Default
----------|-------------|------|--------
arch | Architecture for docker binary (note: Docker only currently supports x86_64) | String | auto-detected (see attributes/default.rb)
group_members | Users to manage in `node['docker']['group']` | Array of Strings | []
init_type | Init type for docker ("runit", "systemd", "sysv", or "upstart") | String | auto-detected (see attributes/default.rb)
install_dir | Installation directory for docker binary (custom setting only valid for non-package installations) | String | auto-detected (see attributes/default.rb)
install_type | Installation type for docker ("binary", "package" or "source") | String | package
ipv4_forward | Sysctl set net.ipv4.ip_forward to 1 | TrueClass, FalseClass | true
ipv6_forward | Sysctl set net.ipv6.conf.all.forwarding to 1 | TrueClass, FalseClass | true
version | Version of docker | String | nil

#### Binary Installation Attributes

These attributes are under the `node['docker']['binary']` namespace.

Attribute | Description | Type | Default
----------|-------------|------|--------
checksum | Optional SHA256 checksum for docker binary | String | auto-detected (see attributes/default.rb)
version | Version of docker binary | String | `node['docker']['version']` (if set) or `latest`
url | URL for downloading docker binary | String | `http://get.docker.io/builds/#{node['kernel']['name']}/#{node['docker']['arch']}/docker-#{node['docker']['binary']['version']}`

#### Package Installation Attributes

These attributes are under the `node['docker']['package']` namespace.

Attribute | Description | Type | Default
----------|-------------|------|--------
action | Action for docker packages ("install", "update", etc.) | String | install
distribution | Distribution for docker packages | String | auto-detected (see attributes/default.rb)
name | Override Docker package name | String | auto-detected (see attributes/default.rb)
repo_url | Repository URL for docker packages | String | auto-detected (see attributes/default.rb)
repo_key | Repository GPG key URL for docker packages | String | https://get.docker.io/gpg

#### Source Installation Attributes

These attributes are under the `node['docker']['source']` namespace.

Attribute | Description | Type | Default
----------|-------------|------|--------
ref | Repository reference for docker source | String | master
url | Repository URL for docker source | String | https://github.com/dotcloud/docker.git

### Docker Daemon Attributes

For more information: http://docs.docker.io/en/latest/reference/commandline/cli/#daemon

These attributes are under the `node['docker']` namespace.

Attribute | Description | Type | Default
----------|-------------|------|--------
api_enable_cors | Enable CORS headers in API | TrueClass, FalseClass | nil
bind_socket (*DEPRECATED*) | Socket path that docker should bind | String | unix:///var/run/docker.sock
bind_uri (*DEPRECATED*) | TCP URI docker should bind | String | nil
bip | Use this CIDR notation address for the network bridge's IP, not compatible with `bridge` | String | nil
bridge | Attach containers to a pre-existing network bridge; use 'none' to disable container networking | String | nil
debug | Enable debug mode | TrueClass, FalseClass | nil (implicitly false)
dns | DNS server(s) for containers | String, Array | nil
dns_search | DNS search domain(s) for containers | String, Array | nil
exec_driver | Execution driver for docker | String | nil (implicitly native as of 0.9.0)
graph | Path to use as the root of the docker runtime | String | nil (implicitly /var/lib/docker)
group | Group for docker socket and group_members | String | nil (implicitly docker)
host | Socket(s) that docker should bind | String, Array | unix:///var/run/docker.sock
http_proxy | HTTP_PROXY environment variable | String | nil
icc | Enable inter-container communication | TrueClass, FalseClass | nil (implicitly true)
ip | Default IP address to use when binding container ports | String | nil (implicitly 0.0.0.0)
iptables | Enable Docker's addition of iptables rules | TrueClass, FalseClass | nil (implicitly true)
logfile | Set custom DOCKER_LOGFILE | String | nil
mtu | Set the containers network MTU | Fixnum | nil (implicitly default route MTU or 1500 if no default route is available)
no_proxy | NO_PROXY environment variable | String | nil
options | Additional options to pass to docker. These could be flags like "-api-enable-cors". | String | nil
pidfile | Path to use for daemon PID file | String | nil (implicitly /var/run/docker.pid)
ramdisk | Set DOCKER_RAMDISK when using RAM disk | TrueClass or FalseClass | false
restart | Restart containers on boot | TrueClass or FalseClass | auto-detected (see attributes/default.rb)
selinux_enabled | Enable SELinux | TrueClass or FalseClass | nil
storage_driver | Storage driver for docker | String | nil
storage_opt | Storage driver options | String, Array | nil
tls | Use TLS | TrueClass, FalseClass | nil (implicitly false)
tlscacert | Trust only remotes providing a certificate signed by the CA given here | String | nil (implicitly ~/.docker/ca.pem)
tlscert | Path to TLS certificate file | String | nil (implicitly ~/.docker/cert.pem)
tlskey | Path to TLS key file | String | nil (implicitly ~/.docker/key.pem)
tlsverify | Use TLS and verify the remote (daemon: verify client, client: verify daemon) | TrueClass, FalseClass | nil (implicitly false)
tmpdir | TMPDIR environment variable | String | nil

### LWRP Attributes

These attributes are under the `node['docker']` namespace.

Attribute | Description | Type | Default
----------|-------------|------|--------
docker_daemon_timeout | Timeout to wait for the docker daemon to start in seconds for LWRP commands | Fixnum | 10

#### docker_container Attributes

These attributes are under the `node['docker']` namespace.

Attribute | Description | Type | Default
----------|-------------|------|--------
container_cmd_timeout | container LWRP default cmd_timeout seconds | Fixnum | 60
container_init_type | Init type for docker containers (nil, "runit", "systemd", "sysv", or "upstart") | String | `node['docker']['init_type']`

#### docker_image Attributes

These attributes are under the `node['docker']` namespace.

Attribute | Description | Type | Default
----------|-------------|------|--------
image_cmd_timeout | image LWRP default cmd_timeout seconds | Fixnum | 300

#### docker_registry Attributes

These attributes are under the `node['docker']` namespace.

Attribute | Description | Type | Default
----------|-------------|------|--------
registry_cmd_timeout | registry LWRP default cmd_timeout seconds | Fixnum | 60

## Recipes

* `recipe[docker]` Installs/Configures Docker
* `recipe[docker::aufs]` Installs/Loads AUFS Linux module
* `recipe[docker::binary]` Installs Docker binary
* `recipe[docker::cgroups]` Installs/configures default platform Control Groups support
* `recipe[docker::devicemapper]` Installs/Configures Device Mapper
* `recipe[docker::group]` Installs/Configures docker group
* `recipe[docker::lxc]` Installs/configures default platform LXC support
* `recipe[docker::package]` Installs Docker via package
* `recipe[docker::runit]` Installs/Starts Docker via runit
* `recipe[docker::source]` Installs Docker via source
* `recipe[docker::systemd]` Installs/Starts Docker via systemd
* `recipe[docker::sysv]` Installs/Starts Docker via SysV
* `recipe[docker::upstart]` Installs/Starts Docker via Upstart

## LWRPs

* docker_container: container operations
* docker_image: image/repository operations
* docker_registry: registry operations

### Getting Started

Here's a quick example of pulling the latest image and running a container with exposed ports (creates service automatically):

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

Maybe you want to automatically update your private registry with changes from your container?

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
docker_container 'crowsnest'

# Save current timestamp
timestamp = Time.new.strftime('%Y%m%d%H%M')

# Commit container changes
docker_container 'crowsnest' do
  repository 'apps'
  tag timestamp
  action :commit
end

# Push image
docker_image 'crowsnest' do
  repository 'apps'
  tag timestamp
  action :push
end
```

See full documentation for each LWRP and action below for more information.

### docker_container

Below are the available actions for the LWRP, default being `run`.

These attributes are associated with all LWRP actions.

Attribute | Description | Type | Default
----------|-------------|------|--------
cmd_timeout | Timeout for docker commands (catchable exception: `Chef::Provider::Docker::Container::CommandTimeout`)| Integer | `node['docker']['container_cmd_timeout']`
command | Command to run in or identify container | String | nil
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

By default, this will handle creating a service for the container when action is run or start. `set['docker']['container_init_type'] = false` or add `init_type false` for LWRP to disable this behavior.

These attributes are associated with this LWRP action.

Attribute | Description | Type | Default
----------|-------------|------|--------
attach | Attach container's stdout/stderr and forward all signals to the process | TrueClass, FalseClass | nil
cidfile | File to store container ID | String | nil
container_name | Name for container/service | String | nil
cookbook | Cookbook to grab any templates | String | docker
cpu_shares | CPU shares for container | Fixnum | nil
detach | Detach from container when starting | TrueClass, FalseClass | nil
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
memory | Set memory limit for container | Fixnum | nil
net | [Configure networking](http://docs.docker.io/reference/run/#network-settings) for container | String | nil
networking (*DEPRECATED*) | Configure networking for container | TrueClass, FalseClass | true
opt | Custom driver options | String, Array | nil
port | Map network port(s) to the container | Fixnum (*DEPRECATED*), String, Array | nil
privileged | Give extended privileges | TrueClass, FalseClass | nil
public_port (*DEPRECATED*) | Map host port to container | Fixnum | nil
publish_exposed_ports | Publish all exposed ports to the host interfaces | TrueClass, FalseClass | false
remove_automatically | Automatically remove the container when it exits (incompatible with detach) | TrueClass, FalseClass | false
socket_template | Template to use for configuring socket (relevent for init_type systemd only) | String | nil
stdin | Attach container's stdin | TrueClass, FalseClass | nil
tty | Allocate a pseudo-tty | TrueClass, FalseClass | nil
user | User to run container | String | nil
volume | Create bind mount(s) with: [host-dir]:[container-dir]:[rw|ro]. If "container-dir" is missing, then docker creates a new volume. | String, Array | nil
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

### docker_image

Below are the available actions for the LWRP, default being `pull`.

These attributes are associated with all LWRP actions.

Attribute | Description | Type | Default
----------|-------------|------|--------
cmd_timeout | Timeout for docker commands (catchable exception: `Chef::Provider::Docker::Image::CommandTimeout`) | Integer | `node['docker']['image_cmd_timeout']`

#### docker_image action :build and :build_if_missing

These attributes are associated with this LWRP action.

Attribute | Description | Type | Default
----------|-------------|------|--------
dockerfile (*DEPRECATED*) | Dockerfile to build image | String | nil
image_url (*DEPRECATED*) | URL to grab image | String | nil
no_cache | Do not use the cache when building the image | TrueClass, FalseClass | false
path (*DEPRECATED*) | Local path to files | String | nil
rm | Remove intermediate containers after a successful build | TrueClass, FalseClass | false
source | Source dockerfile/directory/URL to build | String | nil
tag | Optional tag for image | String | nil

Build image from Dockerfile:

```ruby
docker_image 'myImage' do
  tag 'myTag'
  source 'myImageDockerfile'
  action :build_if_missing
end
```

Build image from remote repository:

```ruby
docker_image 'myImage' do
  source 'example.com/foo/myImage'
  tag 'myTag'
  action :build_if_missing
end
```

Conditionally rebuild image if changes upstream:

```ruby
git "#{Chef::Config[:file_cache_path]}/docker-testcontainerd" do
  repository 'git@github.com:bflad/docker-testcontainerd.git'
  notifies :build, 'docker_image[bflad/testcontainerd]', :immediately
end

docker_image 'bflad/testcontainerd' do
  action :pull_if_missing
end
```

#### docker_image action :import

These attributes are associated with this LWRP action.

Attribute | Description | Type | Default
----------|-------------|------|--------
image_url (*DEPRECATED*) | URL to grab image | String | nil
repository | Optional repository | String | nil
source | Source file/directory/URL | String | nil
tag | Optional tag for image | String | nil

Import image from local directory:

```ruby
docker_image 'test' do
  source '/path/to/test'
  action :import
end
```

Import image from local file:

```ruby
docker_image 'test' do
  source '/path/to/test.tgz'
  action :import
end
```

Import image from remote URL:

```ruby
docker_image 'test' do
  source 'https://example.com/testimage.tgz'
  action :import
end
```

#### docker_image action :insert

*ACTION DEPRECATED AS OF DOCKER 0.10.0*

These attributes are associated with this LWRP action.

Attribute | Description | Type | Default
----------|-------------|------|--------
destination | Destination path/URL | String | nil
source | Source path/URL | String | nil

Insert file from remote URL:

```ruby
docker_image 'test' do
  source 'http://example.com/some/file.txt'
  destination '/container/path/for/some/file.txt'
  action :insert
end
```

#### docker_image action :load

These attributes are associated with this LWRP action.

Attribute | Description | Type | Default
----------|-------------|------|--------
input | Image source (via tar archive file) | String | nil
source | Image source (via stdin) | String | nil

Load repository via input:

```ruby
docker_image 'test' do
  input '/path/to/test.tar'
  action :load
end
```

Load repository via stdin:

```ruby
docker_image 'test' do
  source '/path/to/test.tgz'
  action :load
end
```

#### docker_image action :pull and :pull_if_missing

These attributes are associated with this LWRP action.

Attribute | Description | Type | Default
----------|-------------|------|--------
registry | Optional registry server | String | nil
tag | Optional tag for image | String | nil

Pull latest image every Chef run:

```ruby
docker_image 'busybox'
```

Pull latest image only if missing:

```ruby
docker_image 'busybox' do
  action :pull_if_missing
end
```

Pull tagged image:

```ruby
docker_image 'bflad/test' do
  tag 'not-latest'
end
```

#### docker_image action :push

Push image (after logging in with `docker_registry`):

```ruby
docker_image 'bflad/test' do
  action :push
end
```

#### docker_image action :remove

These attributes are associated with this LWRP action.

Attribute | Description | Type | Default
----------|-------------|------|--------
force | Force removal | TrueClass, FalseClass | nil
no_prune | Do not delete untagged parents | TrueClass, FalseClass | nil

Remove image:

```ruby
docker_image 'busybox' do
  action :remove
end
```

#### docker_image action :save

These attributes are associated with this LWRP action.

Attribute | Description | Type | Default
----------|-------------|------|--------
destination | Destination path (via stdout) | String | nil
output | Destination path (via file) | String | nil
tag | Save specific tag | String | nil

Save repository via file to path:

```ruby
docker_image 'test' do
  destination '/path/to/test.tar'
  action :save
end
```

Save repository via stdout to path:

```ruby
docker_image 'test' do
  destination '/path/to/test.tgz'
  action :save
end
```

#### docker_image action :tag

These attributes are associated with this LWRP action.

Attribute | Description | Type | Default
----------|-------------|------|--------
force | Force operation | Boolean | false
repository | Remote repository | String | nil
tag | Specific tag for image | String | nil

Tag image:

```ruby
docker_image 'test' do
  repository 'bflad'
  tag '1.0.0'
  action :tag
end
```

### docker_registry

These attributes are associated with all LWRP actions.

Attribute | Description | Type | Default
----------|-------------|------|--------
cmd_timeout | Timeout for docker commands (catchable exception: `Chef::Provider::Docker::Registry::CommandTimeout`) | Integer | `node['docker']['registry_cmd_timeout']`

#### docker_registry action :login

These attributes are associated with this LWRP action.

Attribute | Description | Type | Default
----------|-------------|------|--------
email | Registry email | String | nil
password | Registry password | String | nil
username | Registry username | String | nil

Log into or register with public registry:

    docker_registry 'https://index.docker.io/v1/' do
      email 'publicme@example.com'
      username 'publicme'
      password 'hope_this_is_in_encrypted_databag'
    end

Log into private registry with optional port:

    docker_registry 'https://docker-registry.example.com:8443/' do
      username 'privateme'
      password 'still_hope_this_is_in_encrypted_databag'
    end

## Testing and Development

* Quickly testing with Vagrant: [VAGRANT.md](VAGRANT.md)
* Full development and testing workflow with Test Kitchen and friends: [TESTING.md](TESTING.md)

## Contributing

Please see contributing information in: [CONTRIBUTING.md](CONTRIBUTING.md)

## Maintainers

* Tom Duffield (http://tomduffield.com)
* Brian Flad (<bflad417@gmail.com>)
* Fletcher Nichol (<fnichol@nichol.ca>)

## License

Please see licensing information in: [LICENSE](LICENSE)
