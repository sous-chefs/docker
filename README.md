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
* Oracle 6
* RHEL 6
* Ubuntu 12.04
* Ubuntu 12.10
* Ubuntu 13.04
* Ubuntu 13.10 (experimental)

### Cookbooks

[Opscode Cookbooks](https://github.com/opscode-cookbooks/)

* [apt](https://github.com/opscode-cookbooks/apt)
* [git](https://github.com/opscode-cookbooks/git)
* [yum](https://github.com/opscode-cookbooks/yum)

Third-Party Cookbooks

* [golang](https://github.com/NOX73/chef-golang)
* [lxc](https://github.com/hw-cookbooks/lxc)
* [modules](https://github.com/Youscribe/modules-cookbook)

## Attributes

These attributes are under the `node['docker']` namespace.

Attribute | Description | Type | Default
----------|-------------|------|--------
arch | Architecture for docker binary (note: Docker only currently supports x86_64) | String | auto-detected (see attributes/default.rb)
bind_socket | Socket path that docker should bind | String | unix:///var/run/docker.sock
bind_uri | TCP URI docker should bind | String | nil
container_cmd_timeout | container LWRP default cmd_timeout seconds | Fixnum | 60
container_init_type | Init type for docker containers (nil, "systemd", or "upstart") | NilClass or String | `node['docker']['init_type']`
http_proxy | HTTP_PROXY environment variable | String | nil
image_cmd_timeout | image LWRP default cmd_timeout seconds | Fixnum | 300
init_type | Init type for docker ("systemd", "sysv", or "upstart") | String | auto-detected (see attributes/default.rb)
install_dir | Installation directory for docker binary | String | auto-detected (see attributes/default.rb)
install_type | Installation type for docker ("binary", "package" or "source") | String | "package"
options | Additional options to pass to docker. These could be flags like "-api-enable-cors". | String | nil
version | Version of docker | String | nil

### Binary Attributes

These attributes are under the `node['docker']['binary']` namespace.

Attribute | Description | Type | Default
----------|-------------|------|--------
version | Version of docker binary | String | `node['docker']['version'] || latest`
url | URL for downloading docker binary | String | auto-detected (see attributes/default.rb)

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
* `recipe[docker::lxc]` Installs/configures default platform LXC support
* `recipe[docker::package]` Installs Docker via package
* `recipe[docker::source]` Installs Docker via source
* `recipe[docker::systemd]` Installs/Starts Docker via systemd
* `recipe[docker::sysv]` Installs/Starts Docker via SysV
* `recipe[docker::upstart]` Installs/Starts Docker via Upstart

## LWRPs

### docker_container

By default, this will handle creating a service for the container when action is run or start. `set['docker']['container_init_type'] = false` or add `init_type false` for LWRP to disable this behavior.

These attributes are under the `docker_container` LWRP namespace.

Attribute | Description | Type | Default
----------|-------------|------|--------
attach | Attach container's stdout/stderr and forward all signals to the process | TrueClass, FalseClass | nil
cidfile | File to store container ID | String | nil
cmd_timeout | Timeout for docker commands (catchable exception: `Chef::Provider::Docker::Container::CommandTimeout`)| Integer | `node['docker']['container_cmd_timeout']`
command | Command to run in container | String | nil
container_name | Name for container/service | String | nil
cookbook | Cookbook to grab any templates | String | docker
cpu_shares | CPU shares for container | Fixnum | nil
detach | Detach from container when starting | TrueClass, FalseClass | nil
dns | DNS servers for container | String, Array | nil
entrypoint | Overwrite the default entrypoint set by the image | String | nil
env | Environment variables to pass to container | String, Array | nil
expose | Expose a port from the container without publishing it to your host | Fixnum, String, Array | nil
hostname | Container hostname | String | nil
id | Container ID (internally set by LWRP) | String | nil
image | Image for container | String | LWRP name
init_type | Init type for container service handling | FalseClass, String | `node['docker']['container_init_type']`
init_template | Template to use for init configuration | String | nil
link | Add link to another container | String | nil
lxc_conf | Custom LXC options | String, Array | nil
memory | Set memory limit for container | Fixnum | nil
port | Map network port(s) to the container | Fixnum (*DEPRECATED*), String, Array | nil
privileged | Give extended privileges | TrueClass, FalseClass | nil
public_port (*DEPRECATED*) | Map host port to container | Fixnum | nil
publish_exposed_ports | Publish all exposed ports to the host interfaces | TrueClass, FalseClass | false
remove_automatically | Automatically remove the container when it exits (incompatible with detach) | TrueClass, FalseClass | false
running | Container running status (internally set by LWRP) | TrueClass, FalseClass | nil
socket_template | Template to use for configuring socket (relevent for init_type systemd only) | String | nil
stdin | Attach container's stdin | TrueClass, FalseClass | nil
tty | Allocate a pseudo-tty | TrueClass, FalseClass | nil
user | User to run container | String | nil
volume | Create bind mount(s) with: [host-dir]:[container-dir]:[rw|ro]. If "container-dir" is missing, then docker creates a new volume. | String, Array | nil
volumes_from | Mount all volumes from the given container(s) | String | nil
working_directory | Working directory inside the container | String | nil

Run a container:

    docker_container "busybox" do
      command "sleep 9999"
      detach true
    end

Run a container from image (docker-registry for example):

    docker_container "docker-registry" do
      image "samalba/docker-registry"
      detach true
      hostname "xx.xx.xx.xx"
      port 5000
      env "SETTINGS_FLAVOR=local"
      volume "/mnt/docker:/docker-storage"
    end

Stop a running container:

    docker_container "busybox" do
      command "sleep 9999"
      action :stop
    end

Start a stopped container:

    docker_container "busybox" do
      command "sleep 9999"
      action :start
    end

Restart a container:

    docker_container "busybox" do
      command "sleep 9999"
      action :restart
    end

Remove a container:

    docker_container "busybox" do
      command "sleep 9999"
      action :remove
    end

### docker_image

These attributes are under the `docker_image` LWRP namespace.

Attribute | Description | Type | Default
----------|-------------|------|--------
cmd_timeout | Timeout for docker commands (catchable exception: `Chef::Provider::Docker::Image::CommandTimeout`) | Integer | `node['docker']['image_cmd_timeout']`
dockerfile | Dockerfile to build image | String | nil
id | Image ID (internally set by LWRP) | String | nil
image_name | Image name | String | LWRP name
image_url | URL to grab image | String | nil
installed | Image installation status (internally set by LWRP) | TrueClass, FalseClass | nil
installed_tag | - | String | nil
path | Local path to files | String | nil
registry | Registry server | String | nil
repository | Remote repository | String | nil
tag | Specific tag for image | String | nil

Build image from Dockerfile:

    docker_image "myImage" do
      tag "myTag"
      dockerfile myImageDockerfile
      action :build
    end

Build image from remote repository:

    docker_image "myImage" do
      image_url "example.com/foo/myImage"
      tag "myTag"
      action :build
    end

Pull latest image:

    docker_image "busybox"

Pull tagged image:

    docker_image "bflad/test" do
      tag "not-latest"
    end

Import image from URL:

    docker_image "test" do
      image_url "https://example.com/testimage.tgz"
      action :import
    end

Import image from URL with repository/tag information:

    docker_image "test" do
      repository "bflad/test"
      tag "not-latest"
      action :import
    end

Remove image:

    docker_image "busybox" do
      action :remove
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
