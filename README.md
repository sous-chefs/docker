# chef-docker [![Build Status](https://secure.travis-ci.org/bflad/chef-docker.png?branch=master)](http://travis-ci.org/bflad/chef-docker)

## Description

Installs/Configures [Docker](http://docker.io). Please see [COMPATIBILITY.md](COMPATIBILITY.md) for more information about Docker versions that are tested and supported by cookbook versions along with LWRP features.

This cookbook was inspired by @thoward's docker-cookbook: https://github.com/thoward/docker-cookbook

## Requirements

### Chef

* Chef 11+

### Platforms

* CentOS 6
* Debian 7 (experimental)
* Fedora 19
* Fedora 20
* Mac OS X (only docker installation currently)
* Oracle 6 (experimental)
* RHEL 6
* Ubuntu 12.04
* Ubuntu 12.10
* Ubuntu 13.04
* Ubuntu 13.10 (experimental)

### Cookbooks

[Opscode Cookbooks](https://github.com/opscode-cookbooks/)

* [apt](https://github.com/opscode-cookbooks/apt)
* [git](https://github.com/opscode-cookbooks/git)
* [homebrew](https://github.com/opscode-cookbooks/homebrew)
* [yum-epel](https://github.com/opscode-cookbooks/yum-epel)

Third-Party Cookbooks

* [golang](https://github.com/NOX73/chef-golang)
* [lxc](https://github.com/hw-cookbooks/lxc)
* [modules](https://github.com/Youscribe/modules-cookbook)
* [sysctl](https://github.com/onehealth-cookbooks/sysctl)

## Attributes

These attributes are under the `node['docker']` namespace.

Attribute | Description | Type | Default
----------|-------------|------|--------
arch | Architecture for docker binary (note: Docker only currently supports x86_64) | String | auto-detected (see attributes/default.rb)
bind_socket | Socket path that docker should bind | String | unix:///var/run/docker.sock
bind_uri | TCP URI docker should bind | String | nil
container_cmd_timeout | container LWRP default cmd_timeout seconds | Fixnum | 60
container_init_type | Init type for docker containers (nil, "systemd", or "upstart") | NilClass or String | `node['docker']['init_type']`
docker_daemon_timeout | Timeout to wait for the docker daemon to start in seconds | Fixnum | 10
group_members | Manage docker group members | Array of Strings | []
http_proxy | HTTP_PROXY environment variable | String | nil
image_cmd_timeout | image LWRP default cmd_timeout seconds | Fixnum | 300
init_type | Init type for docker ("systemd", "sysv", or "upstart") | String | auto-detected (see attributes/default.rb)
install_dir | Installation directory for docker binary | String | auto-detected (see attributes/default.rb)
install_type | Installation type for docker ("binary", "package" or "source") | String | "package"
options | Additional options to pass to docker. These could be flags like "-api-enable-cors". | String | nil
registry_cmd_timeout | registry LWRP default cmd_timeout seconds | Fixnum | 60
storage_type | Storage driver for docker (nil, "aufs", or "devmapper") | String | auto-detected (see attributes/default.rb)
version | Version of docker | String | nil
virtualization_type | Virtualization driver for docker (nil or "lxc") | String | auto-detected (see attributes/default.rb)

### Binary Attributes

These attributes are under the `node['docker']['binary']` namespace.

Attribute | Description | Type | Default
----------|-------------|------|--------
version | Version of docker binary | String | `node['docker']['version'] || latest`
url | URL for downloading docker binary | String | `http://get.docker.io/builds/#{node['kernel']['name']}/#{node['docker']['arch']}/docker-#{node['docker']['binary']['version']}`

### Package Attributes

These attributes are under the `node['docker']['package']` namespace.

Attribute | Description | Type | Default
----------|-------------|------|--------
distribution | Distribution for docker packages | String | auto-detected (see attributes/default.rb)
repo_url | Repository URL for docker packages | String | auto-detected (see attributes/default.rb)

### Source Attributes

These attributes are under the `node['docker']['source']` namespace.

Attribute | Description | Type | Default
----------|-------------|------|--------
ref | Repository reference for docker source | String | "master"
url | Repository URL for docker source | String | "https://github.com/dotcloud/docker.git"

## Recipes

* `recipe[docker]` Installs/Configures Docker
* `recipe[docker::aufs]` Installs/Loads AUFS Linux module
* `recipe[docker::binary]` Installs Docker binary
* `recipe[docker::cgroups]` Installs/configures default platform Control Groups support
* `recipe[docker::devmapper]` Installs/Configures Device Mapper
* `recipe[docker::group]` Installs/Configures docker group
* `recipe[docker::lxc]` Installs/configures default platform LXC support
* `recipe[docker::package]` Installs Docker via package
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

```
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
socket_template | Template to use for configuring socket (relevent for init_type systemd only) | String | nil

Kill a running container:

```ruby
docker_container 'shipyard' do
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
init_type | Init type for container service handling | FalseClass, String | `node['docker']['container_init_type']`
init_template | Template to use for init configuration | String | nil
link | Add link to another container | String, Array | nil
socket_template | Template to use for configuring socket (relevent for init_type systemd only) | String | nil

Remove a container:

```ruby
docker_container 'shipyard' do
  action :remove
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
entrypoint | Overwrite the default entrypoint set by the image | String | nil
env | Environment variables to pass to container | String, Array | nil
expose | Expose a port from the container without publishing it to your host | Fixnum, String, Array | nil
hostname | Container hostname | String | nil
image | Image for container | String | LWRP name
init_type | Init type for container service handling | FalseClass, String | `node['docker']['container_init_type']`
init_template | Template to use for init configuration | String | nil
link | Add link to another container | String, Array | nil
lxc_conf | Custom LXC options | String, Array | nil
memory | Set memory limit for container | Fixnum | nil
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
  hostname 'xx.xx.xx.xx'
  port 5000
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
source | Source path/URL | String | nil

Load repository from path:

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
destination | Destination path | String | nil

Save repository to path:

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

## Usage

### Default Installation

* Add `recipe[docker]` to your node's run list

## Testing and Development

* Quickly testing with Vagrant: [VAGRANT.md](VAGRANT.md)
* Full development and testing workflow with Test Kitchen and friends: [TESTING.md](TESTING.md)

## Contributing

Please see contributing information in: [CONTRIBUTING.md](CONTRIBUTING.md)

## Maintainers

* Brian Flad (<bflad417@gmail.com>)

## License

Please see licensing information in: [LICENSE](LICENSE)
