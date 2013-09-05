#
# Cookbook Name:: docker
# Attributes:: default
#
# Copyright 2013, Brian Flad
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_attribute "golang"

case node['kernel']['machine']
when "x86_64"
  default['docker']['arch'] = "x86_64"
# If Docker ever supports 32-bit or other architectures
#when %r{i[3-6]86}
#  default['docker']['arch'] = "i386"
else
  default['docker']['arch'] = "x86_64"
end

default['docker']['http_proxy'] = nil

default['docker']['install_type'] = "package"

case node['docker']['install_type']
when "binary"
  default['docker']['install_dir'] = "/usr/local/bin"
when "source"
  default['docker']['install_dir'] = node['go']['gobin']
else
  default['docker']['install_dir'] = "/usr/bin"
end

# Binary attributes
default['docker']['binary']['url'] = "http://get.docker.io/builds/Linux/#{node['docker']['arch']}/docker-latest.tgz"

# Package attributes
case node['platform']
when "ubuntu"
  default['docker']['package']['distribution'] = "docker"
  default['docker']['package']['repo_url'] = "https://get.docker.io/ubuntu"
  default['docker']['package']['repo_key'] = "https://get.docker.io/gpg"
end

# Source attributes
default['docker']['source']['ref'] = "master"
default['docker']['source']['url'] = "https://github.com/dotcloud/docker.git"
