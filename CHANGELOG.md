## 0.24.2

* Bugfix: [GH-43] Better formatting for container LWRP debug logging

## 0.24.1

* Bugfix: Explicitly declare depends and supports in metadata
* Bugfix: Handle container run action if container exists but isn't running

## 0.24.0

* Bugfix: [GH-42] fix(upstart): Install inotify-tools if using upstart
* Enhancement: [GH-38] Allow a user to specify a custom template for their container init configuration

## 0.23.1

* Bugfix: [GH-39] Fix NoMethodError bugs in docker::aufs recipe

## 0.23.0

* Bugfix: Default oracle init_type to sysv
* Enhancement: Experimental Debian 7 package support
* Enhancement: Use new yum-epel cookbook instead of yum::epel recipe
* Enhancement: Use `value_for_platform` where applicable in attributes, requires Chef 11

## 0.22.0

* Enhancement: [GH-35] Use kernel release for package name on saucy and newer
* Enhancement: [GH-37] dont include aufs recipe on ubuntu 13.10 and up; don't require docker::lxc for package installs

## 0.21.0

* Enhancement: [GH-31] More helpful cmd_timeout error messages and catchable exceptions for container (`Chef::Provider::Docker::Container::CommandTimeout`) and image (`Chef::Provider::Docker::Image::CommandTimeout`) LWRPs

## 0.20.0

* Enhancement: Default to package install_type only on distros with known packages
* Enhancement: Initial Oracle 6 platform support via binary install_type
  * https://blogs.oracle.com/wim/entry/oracle_linux_6_5_and
  * http://www.oracle.com/technetwork/articles/servers-storage-admin/resource-controllers-linux-1506602.html
* Enhancement: Split out lxc recipe for default platform lxc handling
* Enhancement: Create cgroups recipe for default platform cgroups handling

## 0.19.1

* Bugfix: [GH-30] apt-get throws exit code 100 when upgrading docker

## 0.19.0

* Enhancement: Add `node['docker']['version']` attribute to handle version for all install_type (recommended you switch to this)
* Enhancement: `default['docker']['binary']['version']` attribute uses `node['docker']['version']` if set 
* Enhancement: Add version handling to package recipe

## 0.18.1

* Bugfix: Remove ExecStartPost from systemd service to match change in docker-io-0.7.0-13

## 0.18.0

* Enhancement: CentOS/RHEL 6 package support via EPEL repository
* Enhancement: Fedora 19/20 package support now in updates (stable) repository
* Enhancement: sysv recipe and init_type

## 0.17.0

* Removed: configuration recipe (see bugfix below)
* Removed: config_dir attribute (see bugfix below)
* Bugfix: Revert back to specifying HTTP_PROXY and "DOCKER_OPTS" natively in systemd/Upstart (mostly to fix up systemd support)
* Bugfix: Add systemctl --system daemon-reload handling to systemd service template
* Bugfix: Add || true to container systemd/Upstart pre-start in case already running
* Bugfix: Locale environment already handled automatically by systemd
* Enhancement: Switch Fedora package installation from goldmann-docker to Fedora updates-testing repository
* Enhancement: Switch container LWRPs to named containers on Fedora since now supported
* Enhancement: Update docker systemd service contents from docker-io-0.7.0-12.fc20
  * Add: Wants/After firewalld.service
  * Add: ExecStartPost firewall-cmd
  * Remove: ExecStartPost iptables commands

## 0.16.0

* Bugfix: Remove protocol from docker systemd ListenStreams
* Bugfix: Lengthen shell_out timeout for stop action in container LWRP to workaround Fedora being slow
* Enhancement: Add service creation to container LWRP by default
  * Please thoroughly test before putting into production!
  * `set['docker']['container_init_type'] = false` or add `init_type false` for the LWRP to disable this behavior
* Enhancement: Add configuration recipe with template
* Enhancement: Add container_cmd_timeout attribute to easily set global container LWRP cmd_timeout default
* Enhancement: Add image_cmd_timeout attribute to easily set global image LWRP cmd_timeout default
* Enhancement: Add cookbook attribute to container LWRP
* Enhancement: Add init_type attribute to container LWRP
* Enhancement: Add locale support for Fedora
* Enhancement: Fail Chef run if `docker run` command errors

## 0.15.0

* Enhancement: Fedora 19/20 package support via [Goldmann docker repo](http://goldmann.fedorapeople.org/repos/docker/)
* Enhancement: docker.service / docker.socket systemd support
* Enhancement: Add `node['docker']['init_type']` attribute for controlling init system

## 0.14.0

* Bugfix: [GH-27] Only use command to determine running container if provided
* Bugfix: [GH-28] Upstart requires full stop and start of service instead of restart if job configuration changes while already running. Note even `initctl reload-configuration` isn't working as expected from http://upstart.ubuntu.com/faq.html#reload
* Enhancement: [GH-26] Add ability to set package action

## 0.13.0

* Bugfix: Move LWRP updated_on_last_action(true) calls so only triggered when something actually gets updated
* Enhancement: Add container LWRP wait action
* Enhancement: Add attach and stdin args to container LWRP start action
* Enhancement: Add link arg to container LWRP remove action
* Enhancement: Use cmd_timeout in container LWRP stop action arguments

## 0.12.0

* Bugfix: Add default bind_uri (nil) to default attributes
* Enhancement: [GH-24] bind_socket attribute added

## 0.11.0

* DEPRACATION: container LWRP Fixnum port attribute: use full String notation from Docker documentation in port attribute instead
* DEPRACATION: container LWRP public_port attribute: use port attribute instead
* Enhancement: Additional container LWRP attributes:
  * cidfile
  * container_name
  * cpu_shares
  * dns
  * expose
  * link
  * lxc_conf
  * publish_exposed_ports
  * remove_automatically
  * volumes_from
* Enhancement: Support Array in container LWRP attributes:
  * env
  * port
  * volume

## 0.10.1

* Bugfix: Set default cmd_timeout in image LWRP to 300 instead of 60 because downloading images can take awhile
* Enhancement: Change docker_test Dockerfile FROM to already downloaded busybox image instead of ubuntu
* Enhancement: Add vagrant-cachier to Vagrantfile

Other behind the scenes changes:
* Made cookbook code Rubocop compliant
* Move licensing information to LICENSE file
* Updated .travis.yml and Gemfile

## 0.10.0

* Enhancement: [GH-22] cmd_timeout, path (image LWRP), working_directory (container LWRP) LWRP attributes
* Bugfix: [GH-25] Install Go environment only when installing from source

## 0.9.1

* Fix to upstart recipe to not restart service constantly (only on initial install and changes)

## 0.9.0

* image LWRP now supports non-stdin build and import actions (thanks @wingrunr21!)

## 0.8.1

* Fix in aufs recipe for FC048 Prefer Mixlib::ShellOut

## 0.8.0

Lots of community contributions this release -- thanks!
* image LWRP now supports builds via Dockerfile
* Additional privileged, public_port, and stdin parameters for container LWRP
* Support specifying binary version for installation
* Fix upstart configuration customization when installing via Apt packages
* Default to Golang 1.1

## 0.7.1

* Use HTTPS for Apt repository

## 0.7.0

* Update APT repository information for Docker 0.6+

## 0.6.2

* Change Upstart config to start on runlevels [2345] instead of just 3

## 0.6.1

* Change env HTTP_PROXY to export HTTP_PROXY in Upstart configuration

## 0.6.0

* Add bind_uri and options attributes

## 0.5.0

* Add http_proxy attribute

## 0.4.0

* Docker now provides precise/quantal/raring distributions for their PPA
* Tested Ubuntu 13.04 support

## 0.3.0

* Initial `container` LWRP

## 0.2.0

* Initial `image` LWRP

## 0.1.0

* Initial release
