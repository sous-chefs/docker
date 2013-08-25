#
# Cookbook Name:: docker
# Recipe:: package
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

case node['platform']
when "ubuntu"
  apt_repository "docker" do
    uri node['docker']['package']['repo_url']
    distribution node['docker']['package']['distribution']
    components [ "main" ]
    key node['docker']['package']['repo_key']
  end
end

package "lxc-docker" do
  options "--force-yes"
end
