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
