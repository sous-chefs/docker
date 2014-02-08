## chef-docker Compatibility ##

### Installation Compatibility ###

Cookbook compatibility based on platform, installation type (`node['docker']['install_type']`), and architecture (`node['docker']['arch']`)

#### Darwin Package x86_64 ####

* Mac OS X via homebrew: 0.30+

#### Darwin Binary x86_64 ####

* Mac OS X: 0.30+

#### Linux Package x86_64 ####

Cookbook Compatibility

Docker Version | CentOS 6 | Debian 7 | Fedora 19 | Fedora 20 | Oracle 6 | RHEL 6 | Ubuntu 12.04 | Ubuntu 12.10 | Ubuntu 13.04 | Ubuntu 13.10
---------------|----------|----------|-----------|-----------|----------|--------|--------------|--------------|--------------|-------------
0.3.2          | -        | -        | -         | -         | -        | -      | 0.1+         | 0.1+         | 0.4+         | -
0.6.0          | -        | -        | -         | -         | -        | -      | 0.7+         | 0.7+         | 0.7+         | -
0.7.0          | 0.18+    | 0.23+    | 0.15+     | 0.15+     | -        | 0.18+  | 0.7+         | 0.7+         | 0.7+         | 0.22+

Test Matrix

Docker Version | CentOS 6 | Debian 7 | Fedora 19 | Fedora 20 | Oracle 6 | RHEL 6 | Ubuntu 12.04 | Ubuntu 12.10 | Ubuntu 13.04 | Ubuntu 13.10
---------------|----------|----------|-----------|-----------|----------|--------|--------------|--------------|--------------|-------------
0.3.2          | -        | -        | -         | -         | -        | -      | 0.1+         | 0.1+         | 0.4+         | -
0.6.0          | -        | -        | -         | -         | -        | -      | 0.7+         | 0.7+         | 0.7+         | -
0.7.0          | 0.18+    | 0.23+    | 0.15+     | 0.15+     | -        | 0.18+  | 0.7+         | 0.7+         | 0.7+         | 0.22+

#### Linux Package i386 ####

Unsupported by Docker.

#### Linux Binary Install ####

Cookbook Compatibility

Docker Version | CentOS 6 | Debian 7 | Fedora 19 | Fedora 20 | Oracle 6 | RHEL 6 | Ubuntu 12.04 | Ubuntu 12.10 | Ubuntu 13.04 | Ubuntu 13.10
---------------|----------|----------|-----------|-----------|----------|--------|--------------|--------------|--------------|-------------
0.3.2          | -        | -        | -         | -         | -        | -      | 0.1+         | 0.1+         | 0.4+         | -
0.7.0          | 0.18+    | -        | 0.15+     | 0.15+     | 0.20+    | 0.18+  | 0.7+         | 0.7+         | 0.7+         | -

Test Matrix

Docker Version | CentOS 6 | Debian 7 | Fedora 19 | Fedora 20 | Oracle 6 | RHEL 6 | Ubuntu 12.04 | Ubuntu 12.10 | Ubuntu 13.04 | Ubuntu 13.10
---------------|----------|----------|-----------|-----------|----------|--------|--------------|--------------|--------------|-------------
0.3.2          | -        | -        | -         | -         | -        | -      | 0.1+         | 0.1+         | 0.4+         | -
0.7.0          | -        | -        | -         | -         | -        | -      | -            | -            | -            | -

### LWRP Compatibility ###

LWRP compatibility based on Docker features.

#### Container ####

Docker Command | Cookbook Version
---------------|-----------------
attach         | -
commit         | 0.25+
cp             | 0.25+
diff           | -
events         | -
export         | 0.25+
inspect        | -
kill           | 0.25+
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
insert         | 0.25+
load           | 0.25+
pull           | 0.2+
push           | 0.25+
rmi            | 0.2+
save           | 0.25+
search         | -
tag            | 0.25+

#### Registry ####

Docker Command | Cookbook Version
---------------|-----------------
login          | 0.25+
