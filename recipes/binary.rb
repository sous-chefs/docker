#
# Cookbook Name:: docker
# Recipe:: binary
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

remote_file "#{Chef::Config[:file_cache_path]}/docker-latest.tgz" do
  source node['docker']['binary']['url']
  owner "root"
  group "root"
  mode 00644
  action :create_if_missing
end

execute "extract_and_install_docker_binary" do
  command "tar -C #{node['docker']['install_dir']} --strip-components=1 -zxf #{Chef::Config[:file_cache_path]}/docker-latest.tgz docker-latest/docker"
  creates "#{node['docker']['install_dir']}/docker"
  action :run
end
