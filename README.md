# chef-docker [![Build Status](https://secure.travis-ci.org/bflad/chef-docker.png?branch=master)](http://travis-ci.org/bflad/chef-docker)

## Description

Installs/Configures [Docker](http://docker.io). Please see [COMPATIBILITY.md](COMPATIBILITY.md) for more information about Docker versions that are tested and supported by cookbook versions along with LWRP features.

This cookbook was inspired by @thoward's docker-cookbook: https://github.com/thoward/docker-cookbook

## Requirements

### Platforms

* Ubuntu 12.04
* Ubuntu 12.10
* Ubuntu 13.04

### Cookbooks

[Opscode Cookbooks](https://github.com/opscode-cookbooks/)

* [apt](https://github.com/opscode-cookbooks/apt)
* [git](https://github.com/opscode-cookbooks/git)

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
http_proxy | HTTP_PROXY environment variable | String | nil
install_dir | Installation directory for docker binary | String | auto-detected (see attributes/default.rb)
install_type | Installation type for docker ("binary", "package" or "source") | String | "package"
options | Additional options to pass to docker. These could be flags like "-api-enable-cors". | String | nil

### Binary Attributes

These attributes are under the `node['docker']['binary']` namespace.

Attribute | Description | Type | Default
----------|-------------|------|--------
version | Version of docker binary | String | latest
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
* `recipe[docker::package]` Installs Docker via package
* `recipe[docker::source]` Installs Docker via source
* `recipe[docker::upstart]` Installs/Starts Docker via Upstart

## LWRPs

### docker_container

Run a container:

    docker_container "busybox" do
      command "sleep 9999"
      detach true
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

### Vagrant

Here's how you can quickly get testing or developing against the cookbook thanks to [Vagrant](http://vagrantup.com/) and [Berkshelf](http://berkshelf.com/).

    vagrant plugin install vagrant-berkshelf
    vagrant plugin install vagrant-cachier
    vagrant plugin install vagrant-omnibus
    git clone git://github.com/bflad/chef-docker.git
    cd chef-docker
    vagrant up BOX # BOX being centos6, debian7, fedora18, fedora19, ubuntu1204, ubuntu1210, or ubuntu1304

You can then SSH into the running VM using the `vagrant ssh BOX` command.

The VM can easily be stopped and deleted with the `vagrant destroy` command. Please see the official [Vagrant documentation](http://docs.vagrantup.com/v2/cli/index.html) for a more in depth explanation of available commands.

### Test Kitchen

Please see documentation in: [TESTING.md](TESTING.md)

## Contributing

Please use standard Github issues/pull requests and if possible, in combination with testing on the Vagrant boxes or Test Kitchen suite.

## Maintainers

* Brian Flad (<bflad417@gmail.com>)

## License

Please see licensing information in: [LICENSE](LICENSE)
