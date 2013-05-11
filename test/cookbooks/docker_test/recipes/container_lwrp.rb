#
# Cookbook Name:: docker_test
# Recipe:: container_lwrp
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

docker_container "busybox" do
  command "sleep 1111"
  detach true
end

docker_container "busybox" do
  command "sleep 2222"
  detach true
end

docker_container "busybox" do
  command "sleep 3333"
  detach true
end

docker_container "busybox" do
  command "sleep 4444"
  detach true
end

docker_container "busybox" do
  command "sleep 5555"
  detach true
end

docker_container "busybox" do
  command "sleep 2222"
  action :restart
end

docker_container "busybox" do
  command "sleep 3333"
  action :stop
end

docker_container "busybox" do
  command "sleep 4444"
  action :stop
end

docker_container "busybox" do
  command "sleep 4444"
  action :start
end

docker_container "busybox" do
  command "sleep 5555"
  action :remove
end
