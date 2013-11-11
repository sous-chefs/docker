## chef-docker Compatibility ##

### Installation Compatibility ###

Cookbook compatibility based on platform, installation type (`node['docker']['install_type']`), and architecture (`node['docker']['arch']`)

#### Linux Package x86_64 ####

Cookbook Compatibility

Docker Version | Ubuntu 12.04 | Ubuntu 12.10 | Ubuntu 13.04
---------------|--------------|----------------------------
0.3.2          | 0.1+         | 0.1+         | 0.4+
0.6.0          | 0.7+         | 0.7+         | 0.7+

Test Matrix

Docker Version | Ubuntu 12.04 | Ubuntu 12.10 | Ubuntu 13.04
---------------|--------------|----------------------------
0.3.2          | 0.1+         | 0.1+         | 0.4+
0.6.0          | 0.7+         | 0.7+         | 0.7+

#### Linux Package i386 ####

Unsupported by Docker.

#### Linux Binary Install ####

Cookbook Compatibility

Docker Version | Ubuntu 12.04 | Ubuntu 12.10 | Ubuntu 13.04
---------------|--------------|----------------------------
0.3.2          | 0.1+         | 0.1+         | 0.4+

Test Matrix

Docker Version | Ubuntu 12.04 | Ubuntu 12.10 | Ubuntu 13.04
---------------|--------------|----------------------------
0.3.2          | 0.1+         | 0.1+         | 0.4+

### LWRP Compatibility ###

LWRP compatibility based on Docker features.

#### Container ####

Docker Command | Cookbook Version
---------------|-----------------
attach         | -
commit         | -
export         | -
inspect        | -
kill           | -
logs           | -
port           | -
start          | 0.3+
stop           | 0.3+
rm             | 0.3+
restart        | 0.3+
run            | 0.3+
wait           | 0.13+

#### Image ####

Docker Command | Cookbook Version
---------------|-----------------
build          | 0.8+
history        | -
import         | 0.9+
pull           | 0.2+
push           | -
rmi            | 0.2+
search         | -
tag            | -
