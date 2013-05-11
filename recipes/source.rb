#
# Cookbook Name:: docker
# Recipe:: source
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

directory "#{node['go']['gopath']}/src/github.com/dotcloud" do
  owner "root"
  group "root"
  mode 00755
  recursive true
  action :create
end

git "#{node['go']['gopath']}/src/github.com/dotcloud/docker" do
  repository node['docker']['source']['url']
  reference node['docker']['source']['ref']
  action :checkout
end

golang_package "github.com/dotcloud/docker/..." do
  action :install
end
