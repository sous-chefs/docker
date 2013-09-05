#
# Cookbook Name:: docker
# Recipe:: default
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

include_recipe "apt" if node['platform'] == "ubuntu"
include_recipe "git" if node['docker']['install_type'] == "source"

package "apt-transport-https"
package "bsdtar"

include_recipe "golang"
include_recipe "lxc"
include_recipe "docker::aufs"
include_recipe "docker::#{node['docker']['install_type']}"
include_recipe "docker::upstart"
