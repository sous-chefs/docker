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
