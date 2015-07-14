
v1.0.0 (unreleased)
--------------------
* Work in progress... moving from "classic" recipe and attribute based
  cookbook to resource based cookbook  
* TODO docker_image and docker_container resources

v0.40.3 (2015-07-14)
--------------------
- remove --no-trunc from docker container status in sysvinit script
- #334 - docker_container tag property (issue 320)
- #331 - docker_container ulimit property
- #328 - Upstart job respawn status detection
- #326 - Upstart job restart behavior fix sysvinit script examples
- #236 - README#324 - Reference DOCKER_OPTS Amazon Linux#325

v0.40.2 (2015-07-14)
--------------------
- Support for older Chef versions

v0.40.1 (2015-07-08)
--------------------
- Changing host property to kind_of Array

v0.40.0  (2015-06-29)
---------------------
Important changes with this release:

* MAJOR INTERFACE CHANGE
* Recipes replaced with docker_service resource* 
* Removing a ton of dependencies
* Storage backends, kernel module loading, etc should now be handled externally
* Updating for Docker 1.6.2
* Preferring binary install method to OS packages

IMPORTANT
* attributes/ will be removed in the next release.
* most are currently non-functional
* All options will be driven through resource properties

v0.37.0
-------

Please note some important changes with this release:

* The sysconfig DOCKER_OPTS improvement in [#250][] can potentially change the behavior of that environment variable as it now allows shell interpolation of any embedded variables. This should not affect most environments. If your DOCKER_OPTS does contains any expected `$`, please escape via `\$` for previous behavior or be sure it will behave as expected before upgrading.
* The daemon restart option (which is deprecated) has been defaulted to `nil` instead of `false` when `node['docker']['container_init_type']` is set to prevent issues with container restart policies. If you're dependent on the daemon option, please be sure to update your `node['docker']['restart']`  appropriately.
* This release also defaults systemd docker host to `fd://` to match upstream, enabling socket activation properly. Adjust `node['docker']['host']` if necessary.

* Bugfix: [#239][]: Upstart: install inotify tools only once (avoid CHEF-3694 warning) (thanks jperville)
* Bugfix: [#240][]: Fixed dead service containers not being restarted on docker_container :run (thanks jperville)
* Bugfix: [#244][]: Made docker_container action :remove remove the actual upstart service file (thanks jperville)
* Bugfix: [#246][]: Lengthen shell_out timeout as workaround for slow docker_container action stop (thanks jperville)
* Bugfix: [#258][]: Fix checking docker container status on debian (thanks fxposter)
* Bugfix: [#260][]: Fix accidental port changing when using systemd templates (thanks fxposter)
* Bugfix: [#266][]: Get tests working on master (thanks tduffield)
* Bugfix: [#267][]: Replace outdated testcontainerd (thanks tduffield)
* Bugfix: [#269][]: Fix tests on Travis by following Rubocop style guidelines (container LWRP) (thanks fxposter)
* Bugfix: [#280][] / [#281][]: Fix port handling when omitted in container LWRP (thanks databus23)
* Bugfix: [#284][] / [#285][]: runit finish script to stop a container (thanks xmik)
* Bugfix: [#288][]: Fix docker.socket unit for RHEL7 (thanks databus23)
* Bugfix: [#292][]: readme formatting fix (thanks wormzer)
* Improvement: [#208][]: Add CentOS/RHEL 7 support (thanks dermusikman and intoximeters)
* Improvement: [#232][]: Added support for insecure-registry docker daemon option (thanks jperville)
* Improvement: [#233][] / [#234][]: Added support for registry-mirror docker daemon option (thanks jperville and tarnfeld)
* Improvement: [#237][]: Deprecate the restart daemon option (thanks jperville)
* Improvement: [#238][]: Added docker_container restart attribute (thanks jperville)
* Improvement: [#242][]: Added docker_container action :create (thanks jperville)
* Improvement: [#245][]: Add a Gitter chat badge to README.md (thanks tduffield)
* Improvement: [#250][]: Use double-quotes for DOCKER_OPTS (thanks rchekaluk)
* Improvement: [#259][]: Use registry on image inspection (thanks fxposter)
* Improvement: [#263][]: Add additional_host attribute to container resource (thanks fxposter)
* Improvement: [#264][] / [#265][]: Access keyserver.ubuntu.com on port 80 (thanks sauraus)
* Improvement: [#268][]: Updated the /etc/init/docker.conf template (thanks jperville)
* Improvement: [#276][]: Added support for docker options device and cap-add (thanks hvolkmer)
* Improvement: [#279][]: Allow docker_container memory to have String value (eg. memory='1G') (thanks jperville)
* Improvement: [#287][]: redhat 7 does not need the epel repository (thanks databus23)
* Improvement: [#289][]: Update systemd service/socket files (from upstream) (thanks databus23)
* Improvement: [#296][]: Default systemd to fd:// as well as use upstream MountFlags=slave and LimitCORE=infinity
* Improvement: [#297][]: Update docker daemon SysV init scripts with upstream improvements
* Improvement: [#298][]: Further deprecate daemon restart flag by default, which interferes with restart policies

## 0.36.0
* Bugfix: [#181][]: Fixed remove_link action (thanks jperville).
* Bugfix: [#185][]: Fix for non idempotent run action on docker_container (thanks bplunkert).
* Bugfix: [#188][]: Applied temporary workaround to address the libcgmanager error to users running LXC on Ubuntu 14.04.
* Bugfix: [#196][]: Address Helpers module naming conflict (thanks sethrosenblum).
* Bugfix: [#200][]: Fix how service actions are handled by docker_container resource (thanks brianhartsock).
* Bugfix: [#202][]: Correctly check for the kernel.release version on Debian (thanks Tritlo, paweloczadly).
* Bugfix: [#203][]: Fix pull notifications for tagged images (thanks hobofan).
* Bugfix: [#205][]: Fix current_resource.name assignments in docker_container provider (thanks jperville).
* Bugfix: [#206][]: Fixes to container name detection (thanks jperville).
* Enhancement: [#217][]: Explicitly set key and keyserver for docker apt repository (thanks sethrosenblum).
* Improvement: Pull in init script changes from upstream for sysv and systemd.
* Bugfix: [#219][]: Explicitly set Upstart provider for Ubuntu 14.04 and 14.10 (thanks methodx).
* Improvement: [#220][]: Create graph directory if it is specified (thanks jontg).
* Bugfix: [#224][]: Fix runit container template to properly use exec (thanks waisbrot).
* Bugfix: Appropriately check for LXC when using the binary recipe on Fedora.
* Bugfix: Implement workaround for docker/docker#2702 on Ubuntu 14.10.
* Enhancement: [#221][]: Added NO_PROXY support (thanks jperville).
* Various Test Suite Modifications
  * Enhancement: [#192][]: Allow image tags in serverspec matching (thanks bplunkert).
  * Bugfix: [#223][]: Convert a few occurrences of old 'should' rspec syntax to 'expect' (thanks jperville).
  * Disable a few platforms that are experiencing bugs unrelated to core functionality.
  * Address ChefSpec 4.1 deprecation warnings.
  * Update Berksfile to reference supermarket.getchef.com instead of api.berkshelf.com

## 0.35.2

* Bugfix: [#171][]: Default Ubuntu 14.04 to Docker PPA
* Bugfix: [#175][]: Do not set --selinux-enabled in opts unless explicitly defined for older versions
* Bugfix: [#176][]: Use docker host attribute in docker_container Upstart inotifywait

## 0.35.1

* Bugfix: [#172][]: Generate no cidfile by default, even when deploying as service
* Bugfix: [#173][]: Updated docker upstart script (should fix service docker restart)

## 0.35.0

After a long personal hiatus (sorry!), this is the last minor release before 1.0 of the cookbook. If you can handle the Docker port number change and don't use anything deprecated, upgrading to 1.0.X from 0.35.X of the cookbook should be very easy.

This release has a bunch of changes and hasn't been fully tested yet. Wanted to get it out there for broad testing. Please use caution!

Major kudos to @tduffield for the [#147][] PR, which includes:
* Binary Installation
  * Added missing dependency resolution for using the binary.
* Dependency Checks
  * Added `docker::dep_check` that will take an action if certain dependencies are not met.
    * `node[docker][alert_on_error_action] = :fatal` will kill the chef run and print the error message.
    * `node[docker][alert_on_error_action] = :warn` will print the error message but continue with the chef run. There is no guarantee that it will succeed though.
* KitchenCI
  * Copied MiniTests to ServerSpec Tests
  * Added new platforms (Debian 7.4)
  * Changed provisioner from chef-solo to chef-zero
  * Removed Ubuntu 12.10 because it is not supported by Docker and the Kernel is bad and fails all the tests.
  * Removed tests for the source recipe. The dotcloud/docker repo actually doesn’t build any Go deliverables.
    * I think that the source recipe needs to be completely refactored.

Other awesome work merged:

* [#142][]: Bugfix: Redeploy breaks when a link is present
* [#139][]/[#153][]/[#154][]/[#156][]/[#157][]: Bugfix: container/image ID given as nil, fixes deprecated -notrunc
* [#164][]: Bugfix: Removing a container should also remove its cidfile
* [#166][]: Bugfix: Fix docker_inspect_id for Docker 1.0+
* [#158][]/[#160][]/[#165][]: Bugfix: Fix NameError when displaying error messages for timed-out commands
* [#169][]: Bugfix: Specify Upstart as service provider for cgroup on Ubuntu 14.04 (workaround for CHEF-5276, fixed in Chef 11.14)
* [#137][]/[#138][]: Enhancement: Experimental Ubuntu 14.04 LTS support
* [#144][]: Enhancement: Experimental Amazon linux support
* [#150][]/[#152][]: Enhancement: Add net attribute, deprecate networking
* [#168][]: Enhancement: Allow override of package name
* [#161][]: Enhancement: Add minitest case for SysV service
* [#149][]: Enhancement: Add --selinux-enabled daemon flag
* Enhancement: container LWRP remove_link and remove_volume actions
* Enhancement: Add storage-opt daemon flag
* Enhancement: Add Docker 0.11.0, 0.11.1, 0.12.0, 1.0.0, 1.0.1 binary checksums

## 0.34.2

* [#141][]: Bugfix/Enhancement: Fix and enhance docker_image pull/push behavior with Docker 0.10
  * Removes deprecated --registry and --tag CLI args from docker_image pull
  * Adds support for registry attribute usage in docker_image pull and push
  * Adds support for tag attribute usage in docker_image push

## 0.34.1

* [#134][]: Bugfix: Fix docker_registry login handling, fixes #114

## 0.34.0

Attributes now available for all docker daemon flags as well as system IP forwarding.

* REMOVED: container_dns* attributes (use replacement dns* attributes on daemon for all containers or docker_container dns* attributes instead)
* DEPRECATED: bind_* attributes to match docker terminology (use host attribute instead)
* Bugfix: [#132][]: Do Not Explicitly Set storage_driver Attribute
* Bugfix: [#133][]: Remove explicit false defaults in resources
* Bugfix: [#114][]: Error executing action login on resource docker_registry
* Enhancement: [#115][]: Add IP forwarding attributes
* Enhancement: [#116][]: Docker 0.10.0: Add --no-prune to docker rmi
* Enhancement: [#117][]: Docker 0.10.0: Add --output flag to docker save (as well as tag support)
* Enhancement: [#118][]: Docker 0.10.0: Add --input flag to docker load
* Enhancement: [#119][]: Docker 0.10.0: Add support for --env-file to load environment variables from files
* Enhancement: [#120][]: Docker 0.10.0: Deprecate docker insert
* Enhancement: [#123][]: Add docker kill --signal
* Enhancement: [#124][]: Add all docker daemon options as attributes
* Enhancement: [#125][]: Use dns* attributes to set docker daemon options, not defaults per-container
* Enhancement: [#128][]: Add checksum attribute for binary downloads
* Enhancement: [#126][]: Set long option names for specified docker daemon options
* Enhancement: [#127][]: Use a helper function to specify single line docker daemon options

## 0.33.1

* Bugfix: [#112][]: Defines runner methods for ChefSpec matchers
* Bugfix: [#113][]: [D-15] Fedora 19 installs Docker 0.8.1, does not have the -G or -e flag

## 0.33.0

This release deprecates AUFS/device-mapper handling from chef-docker, but provides backwards compatibility by still including the default recipe of the new cookbooks. Please update your dependencies, Github watching/issues, and recipes to reflect the two new community cookbooks:
* aufs: [aufs on community site](http://community.opscode.com/cookbooks/aufs) / [chef-aufs on Github](https://github.com/bflad/chef-aufs)
* device-mapper: [device-mapper on community site](http://community.opscode.com/cookbooks/device-mapper) / [chef-device-mapper on Github](https://github.com/bflad/chef-device-mapper)

* Bugfix: [#109][]: Remove on lxc-net start from docker Upstart
* Enhancement: [#88][]: Migrate AUFS logic to separate cookbook
* Enhancement: [#90][]: Migrate device-mapper logic to separate cookbook
* Enhancement: [#110][]: Add docker Upstart pre-start script and limits configuration
* Enhancement: [#105][]: Add --label for docker run
* Enhancement: [#106][]: Add --opt for docker run
* Enhancement: [#107][]: Add --networking for docker run
* Enhancement: [#108][]: Add --dns-search for docker run
* Enhancement: [#104][]: Add TMPDIR
* Enhancement: [#111][]: Add DOCKER_LOGFILE configuration
* Enhancement: container_dns* attributes to set --dns and --dns-search for all containers

## 0.32.2

* Bugfix: [#101][]: Explicitly install lxc on Ubuntu (when lxc is exec_driver; continue to fully support LXC as a default installation path since its been since Docker 0.1)
* Bugfix: [#103][]: Fix host argument (in docker run)

## 0.32.1

* Bugfix: [#98][]: Ensure Ruby 1.8 syntax is supported
* Bugfix: Skip empty Array values in cli_args helper

## 0.32.0

_If you're using CentOS/RHEL with EPEL, upcoming docker-io 0.9.0 package upgrade can be tracked at [Bugzilla 1074880](https://bugzilla.redhat.com/show_bug.cgi?id=1074880)_

This release includes Docker 0.9.0 changes and defaults, such as setting exec_driver to libcontainer ("native"), setting -rm on docker build, double dash arguments on the CLI, additional flags, etc.

* DEPRECATED: Rename storage_type attribute to storage_driver to [match Docker terminology](http://docs.docker.io/en/latest/reference/commandline/cli/#daemon) (storage_type will be removed in chef-docker 1.0)
* DEPRECATED: Rename virtualization_type attribute to exec_driver to [match Docker terminology](http://docs.docker.io/en/latest/reference/commandline/cli/#daemon) (virtualization_type will be removed in chef-docker 1.0)
* Bugfix: [#80][]: Use double dashed arguments on CLI
* Bugfix: Surround String values on CLI with quotes
* Enhancement: [#77][]: Improved docker ps handling
* Enhancement: [#78][]: Docker 0.9.0: Make --rm the default for docker build
* Enhancement: [#81][]: Docker 0.9.0: Add a -G option to specify the group which unix sockets belong
* Enhancement: [#82][]: Docker 0.9.0: Add -f flag to docker rm to force removal of running containers
* Enhancement: Add -f flag for docker rmi to force removal of images
* Enhancement: [#83][]: Docker 0.9.0: Add DOCKER_RAMDISK environment variable to make Docker work when the root is on a ramdisk
* Enhancement: [#84][]: Docker 0.9.0: Add -e flag for execution driver
* Enhancement: [#85][]: Docker 0.9.0: Default to libcontainer
* Enhancement: [#86][]: Add Chefspec LWRP matchers

## 0.31.0

Lots of init love this release. Now supporting runit.

Please note change of storage_type attribute from devmapper to devicemapper (and associated recipe name change) to match docker's name for the driver.

Cookbook now automatically adds -s option to init configurations if storage_type is defined, which is it by default. If you were specifying -s in the options attribute, you no longer need to do so. In my quick testing, docker daemon doesn't seem to mind if -s is specified twice on startup, although you'll probably want to get rid of the extra specification.

I've also dropped the LANG= and LC_ALL= locale environment settings from the Upstart job configuration. Its not specified in the default docker job. Please open an issue in docker project and here if for some reason this is actually necessary.

* Bugfix: Match devicemapper storage_type attribute to match docker driver name (along with recipe name)
* Enhancement: [#72][]: Add initial runit init_type
* Enhancement: [#60][]: Automatically set docker -d -s from storage_type attribute
* Enhancement: Simplify default/sysconfig file into one template (docker.sysconfig.erb) and source into SysV/Upstart init configurations
* Enhancement: Add Debian docker daemon SysV init template

## 0.30.2

* Bugfix: [#68][]: Fix CommandTimeout handling in LWRPs
* Bugfix: [#67][]: Fix argument order to pull when tag specified

## 0.30.1

Public or private registry login should now correctly occur and login once per credentials change.

* Bugfix: [#64][]: Correct CLI ordering of registry login
* Bugfix: [#65][]: login command skipped in registry provider
* Enhancement: registry provider current resource attributes loaded from .dockercfg

## 0.30.0

Awesome work by [@jcrobak][] to close out two issues ([#49][] and [#52][]) with [#62][]. Note change below in image build action.

* Bugfix: [#52][]: return codes of docker commands not verified
* Bugfix: Add missing pull_if_missing action to image resource
* Enhancement: [#56][]: Switch build action to build_if_missing, build action now builds each run (be careful with image growth!)
* Enhancement: [#59][]: Add Mac OS X installation support
* Enhancement: [#49][]: Add docker_cmd_timeout attribute and daemon verification
* Enhancement: [#58][]: Add container redeploy action
* Enhancement: [#63][]: Add group_members attribute and group recipe to manage docker group

## 0.29.0

* Enhancement: [#57][]: Implement id checking when determining current_resource
  * Added to both container and image LWRPs
* Enhancement: Set created and status attributes for current container resources (for handlers, wrappers, etc.)
* Enhancement: Set created and virtual_size attributes for image resource (for handlers, wrappers, etc.)

## 0.28.0

* Enhancement: [#55][]: image LWRP pull action now attempts pull every run (use pull_if_missing action for old behavior)

## 0.27.1

* Bugfix: [#51][]: container LWRP current_resource attribute matching should also depend on container_name

## 0.27.0

* Enhancement: [#48][]: Accept FalseClass CLI arguments (also explicitly declare =true for TrueClass CLI arguments)

## 0.26.0

* Bugfix: Add SysV init script for binary installs
* Enhancement: Add storage_type and virtualization_type attributes
* Enhancement: Initial devmapper support for binary installs on CentOS/Ubuntu
* Enhancement: [#47][] Debian-specific container SysV init script
* Enhancement: [#46][] Add rm attribute for build action on image LWRP
* Enhancement: Add no_cache attribute for build action on image LWRP

## 0.25.1

* Bugfix: [#44][] Add missing run attribute for commit action on container LWRP

## 0.25.0

* DEPRECATED: image LWRP dockerfile, image_url, and path attributes (replaced with source attribute)
* Bugfix: Use docker_cmd for container LWRP remove and restart actions
* Enhancement: Add registry LWRP with login action
* Enhancement: Standardize on "smart" and reusable destination and source attributes for container and image LWRPs to define paths/URLs for various operations
* Enhancement: Add commit, cp, export, and kill actions to container LWRP
* Enhancement: Add insert, load, push, save, and tag actions to image LWRP
* Enhancement: Add local file and directory support to import action of image LWRP
* Enhancement: Add Array support to container LWRP link attribute
* Enhancement: Cleaned up LWRP documentation

## 0.24.2

* Bugfix: [#43][] Better formatting for container LWRP debug logging

## 0.24.1

* Bugfix: Explicitly declare depends and supports in metadata
* Bugfix: Handle container run action if container exists but isn't running

## 0.24.0

* Bugfix: [#42][] fix(upstart): Install inotify-tools if using upstart
* Enhancement: [#38][] Allow a user to specify a custom template for their container init configuration

## 0.23.1

* Bugfix: [#39][] Fix NoMethodError bugs in docker::aufs recipe

## 0.23.0

* Bugfix: Default oracle init_type to sysv
* Enhancement: Experimental Debian 7 package support
* Enhancement: Use new yum-epel cookbook instead of yum::epel recipe
* Enhancement: Use `value_for_platform` where applicable in attributes, requires Chef 11

## 0.22.0

* Enhancement: [#35][] Use kernel release for package name on saucy and newer
* Enhancement: [#37][] dont include aufs recipe on ubuntu 13.10 and up; don't require docker::lxc for package installs

## 0.21.0

* Enhancement: [#31][] More helpful cmd_timeout error messages and catchable exceptions for container (`Chef::Provider::Docker::Container::CommandTimeout`) and image (`Chef::Provider::Docker::Image::CommandTimeout`) LWRPs

## 0.20.0

* Enhancement: Default to package install_type only on distros with known packages
* Enhancement: Initial Oracle 6 platform support via binary install_type
  * https://blogs.oracle.com/wim/entry/oracle_linux_6_5_and
  * http://www.oracle.com/technetwork/articles/servers-storage-admin/resource-controllers-linux-1506602.html
* Enhancement: Split out lxc recipe for default platform lxc handling
* Enhancement: Create cgroups recipe for default platform cgroups handling

## 0.19.1

* Bugfix: [#30][] apt-get throws exit code 100 when upgrading docker

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

* Bugfix: [#27][] Only use command to determine running container if provided
* Bugfix: [#28][] Upstart requires full stop and start of service instead of restart if job configuration changes while already running. Note even `initctl reload-configuration` isn't working as expected from http://upstart.ubuntu.com/faq.html#reload
* Enhancement: [#26][] Add ability to set package action

## 0.13.0

* Bugfix: Move LWRP updated_on_last_action(true) calls so only triggered when something actually gets updated
* Enhancement: Add container LWRP wait action
* Enhancement: Add attach and stdin args to container LWRP start action
* Enhancement: Add link arg to container LWRP remove action
* Enhancement: Use cmd_timeout in container LWRP stop action arguments

## 0.12.0

* Bugfix: Add default bind_uri (nil) to default attributes
* Enhancement: [#24][] bind_socket attribute added

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

* Enhancement: [#22][] cmd_timeout, path (image LWRP), working_directory (container LWRP) LWRP attributes
* Bugfix: [#25][] Install Go environment only when installing from source

## 0.9.1

* Fix to upstart recipe to not restart service constantly (only on initial install and changes)

## 0.9.0

* image LWRP now supports non-stdin build and import actions (thanks [@wingrunr21][]!)

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

[#22]: https://github.com/bflad/chef-docker/issues/22
[#24]: https://github.com/bflad/chef-docker/issues/24
[#25]: https://github.com/bflad/chef-docker/issues/25
[#26]: https://github.com/bflad/chef-docker/issues/26
[#27]: https://github.com/bflad/chef-docker/issues/27
[#28]: https://github.com/bflad/chef-docker/issues/28
[#30]: https://github.com/bflad/chef-docker/issues/30
[#31]: https://github.com/bflad/chef-docker/issues/31
[#35]: https://github.com/bflad/chef-docker/issues/35
[#37]: https://github.com/bflad/chef-docker/issues/37
[#38]: https://github.com/bflad/chef-docker/issues/38
[#39]: https://github.com/bflad/chef-docker/issues/39
[#42]: https://github.com/bflad/chef-docker/issues/42
[#43]: https://github.com/bflad/chef-docker/issues/43
[#44]: https://github.com/bflad/chef-docker/issues/44
[#46]: https://github.com/bflad/chef-docker/issues/46
[#47]: https://github.com/bflad/chef-docker/issues/47
[#48]: https://github.com/bflad/chef-docker/issues/48
[#49]: https://github.com/bflad/chef-docker/issues/49
[#51]: https://github.com/bflad/chef-docker/issues/51
[#52]: https://github.com/bflad/chef-docker/issues/52
[#55]: https://github.com/bflad/chef-docker/issues/55
[#56]: https://github.com/bflad/chef-docker/issues/56
[#57]: https://github.com/bflad/chef-docker/issues/57
[#58]: https://github.com/bflad/chef-docker/issues/58
[#59]: https://github.com/bflad/chef-docker/issues/59
[#60]: https://github.com/bflad/chef-docker/issues/60
[#62]: https://github.com/bflad/chef-docker/issues/62
[#63]: https://github.com/bflad/chef-docker/issues/63
[#64]: https://github.com/bflad/chef-docker/issues/64
[#65]: https://github.com/bflad/chef-docker/issues/65
[#67]: https://github.com/bflad/chef-docker/issues/67
[#68]: https://github.com/bflad/chef-docker/issues/68
[#72]: https://github.com/bflad/chef-docker/issues/72
[#77]: https://github.com/bflad/chef-docker/issues/77
[#78]: https://github.com/bflad/chef-docker/issues/78
[#80]: https://github.com/bflad/chef-docker/issues/80
[#81]: https://github.com/bflad/chef-docker/issues/81
[#82]: https://github.com/bflad/chef-docker/issues/82
[#83]: https://github.com/bflad/chef-docker/issues/83
[#84]: https://github.com/bflad/chef-docker/issues/84
[#85]: https://github.com/bflad/chef-docker/issues/85
[#86]: https://github.com/bflad/chef-docker/issues/86
[#88]: https://github.com/bflad/chef-docker/issues/88
[#89]: https://github.com/bflad/chef-docker/issues/89
[#90]: https://github.com/bflad/chef-docker/issues/90
[#91]: https://github.com/bflad/chef-docker/issues/91
[#98]: https://github.com/bflad/chef-docker/issues/98
[#101]: https://github.com/bflad/chef-docker/issues/101
[#103]: https://github.com/bflad/chef-docker/issues/103
[#104]: https://github.com/bflad/chef-docker/issues/104
[#105]: https://github.com/bflad/chef-docker/issues/105
[#106]: https://github.com/bflad/chef-docker/issues/106
[#107]: https://github.com/bflad/chef-docker/issues/107
[#108]: https://github.com/bflad/chef-docker/issues/108
[#109]: https://github.com/bflad/chef-docker/issues/109
[#110]: https://github.com/bflad/chef-docker/issues/110
[#111]: https://github.com/bflad/chef-docker/issues/111
[#112]: https://github.com/bflad/chef-docker/issues/112
[#113]: https://github.com/bflad/chef-docker/issues/113
[#114]: https://github.com/bflad/chef-docker/issues/114
[#115]: https://github.com/bflad/chef-docker/issues/115
[#116]: https://github.com/bflad/chef-docker/issues/116
[#117]: https://github.com/bflad/chef-docker/issues/117
[#118]: https://github.com/bflad/chef-docker/issues/118
[#119]: https://github.com/bflad/chef-docker/issues/119
[#120]: https://github.com/bflad/chef-docker/issues/120
[#123]: https://github.com/bflad/chef-docker/issues/123
[#124]: https://github.com/bflad/chef-docker/issues/124
[#125]: https://github.com/bflad/chef-docker/issues/125
[#126]: https://github.com/bflad/chef-docker/issues/126
[#127]: https://github.com/bflad/chef-docker/issues/127
[#128]: https://github.com/bflad/chef-docker/issues/128
[#132]: https://github.com/bflad/chef-docker/issues/132
[#133]: https://github.com/bflad/chef-docker/issues/133
[#134]: https://github.com/bflad/chef-docker/issues/134
[#137]: https://github.com/bflad/chef-docker/issues/137
[#138]: https://github.com/bflad/chef-docker/issues/138
[#139]: https://github.com/bflad/chef-docker/issues/139
[#141]: https://github.com/bflad/chef-docker/issues/141
[#142]: https://github.com/bflad/chef-docker/issues/142
[#144]: https://github.com/bflad/chef-docker/issues/144
[#147]: https://github.com/bflad/chef-docker/issues/147
[#149]: https://github.com/bflad/chef-docker/issues/149
[#150]: https://github.com/bflad/chef-docker/issues/150
[#152]: https://github.com/bflad/chef-docker/issues/152
[#153]: https://github.com/bflad/chef-docker/issues/153
[#154]: https://github.com/bflad/chef-docker/issues/154
[#156]: https://github.com/bflad/chef-docker/issues/156
[#157]: https://github.com/bflad/chef-docker/issues/157
[#158]: https://github.com/bflad/chef-docker/issues/158
[#160]: https://github.com/bflad/chef-docker/issues/160
[#161]: https://github.com/bflad/chef-docker/issues/161
[#164]: https://github.com/bflad/chef-docker/issues/164
[#165]: https://github.com/bflad/chef-docker/issues/165
[#166]: https://github.com/bflad/chef-docker/issues/166
[#168]: https://github.com/bflad/chef-docker/issues/168
[#169]: https://github.com/bflad/chef-docker/issues/169
[#171]: https://github.com/bflad/chef-docker/issues/171
[#172]: https://github.com/bflad/chef-docker/issues/172
[#173]: https://github.com/bflad/chef-docker/issues/173
[#175]: https://github.com/bflad/chef-docker/issues/175
[#176]: https://github.com/bflad/chef-docker/issues/176
[#181]: https://github.com/bflad/chef-docker/issues/181
[#185]: https://github.com/bflad/chef-docker/issues/185
[#188]: https://github.com/bflad/chef-docker/issues/188
[#192]: https://github.com/bflad/chef-docker/issues/192
[#196]: https://github.com/bflad/chef-docker/issues/196
[#200]: https://github.com/bflad/chef-docker/issues/200
[#202]: https://github.com/bflad/chef-docker/issues/202
[#203]: https://github.com/bflad/chef-docker/issues/203
[#205]: https://github.com/bflad/chef-docker/issues/205
[#206]: https://github.com/bflad/chef-docker/issues/206
[#208]: https://github.com/bflad/chef-docker/issues/208
[#217]: https://github.com/bflad/chef-docker/issues/217
[#219]: https://github.com/bflad/chef-docker/issues/219
[#220]: https://github.com/bflad/chef-docker/issues/220
[#221]: https://github.com/bflad/chef-docker/issues/221
[#223]: https://github.com/bflad/chef-docker/issues/223
[#224]: https://github.com/bflad/chef-docker/issues/224
[#232]: https://github.com/bflad/chef-docker/issues/232
[#233]: https://github.com/bflad/chef-docker/issues/233
[#234]: https://github.com/bflad/chef-docker/issues/234
[#237]: https://github.com/bflad/chef-docker/issues/237
[#238]: https://github.com/bflad/chef-docker/issues/238
[#239]: https://github.com/bflad/chef-docker/issues/239
[#240]: https://github.com/bflad/chef-docker/issues/240
[#242]: https://github.com/bflad/chef-docker/issues/242
[#244]: https://github.com/bflad/chef-docker/issues/244
[#245]: https://github.com/bflad/chef-docker/issues/245
[#246]: https://github.com/bflad/chef-docker/issues/246
[#250]: https://github.com/bflad/chef-docker/issues/250
[#258]: https://github.com/bflad/chef-docker/issues/258
[#259]: https://github.com/bflad/chef-docker/issues/259
[#260]: https://github.com/bflad/chef-docker/issues/260
[#263]: https://github.com/bflad/chef-docker/issues/263
[#264]: https://github.com/bflad/chef-docker/issues/264
[#265]: https://github.com/bflad/chef-docker/issues/265
[#266]: https://github.com/bflad/chef-docker/issues/266
[#267]: https://github.com/bflad/chef-docker/issues/267
[#268]: https://github.com/bflad/chef-docker/issues/268
[#269]: https://github.com/bflad/chef-docker/issues/269
[#276]: https://github.com/bflad/chef-docker/issues/276
[#279]: https://github.com/bflad/chef-docker/issues/279
[#280]: https://github.com/bflad/chef-docker/issues/280
[#281]: https://github.com/bflad/chef-docker/issues/281
[#284]: https://github.com/bflad/chef-docker/issues/284
[#285]: https://github.com/bflad/chef-docker/issues/285
[#287]: https://github.com/bflad/chef-docker/issues/287
[#289]: https://github.com/bflad/chef-docker/issues/289
[#292]: https://github.com/bflad/chef-docker/issues/292
[#296]: https://github.com/bflad/chef-docker/issues/296
[#297]: https://github.com/bflad/chef-docker/issues/297
[#298]: https://github.com/bflad/chef-docker/issues/298
[@jcrobak]: https://github.com/jcrobak
[@wingrunr21]: https://github.com/wingrunr21
