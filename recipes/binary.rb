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

# Temporary destination
cache_path = "#{Chef::Config[:file_cache_path]}/docker-latest.tgz"

# Download docker binary to cache
remote_file cache_path do
  source node['docker']['binary']['url']
  action :create_if_missing
end

# Copy cache file to docker destination
file "#{node['docker']['install_dir']}/docker" do
      content IO.read(cache_path)
      only_if {File.exists?(cache_path)}
      owner "root"
      group "root"
      mode "0755"
end

