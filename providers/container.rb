#
# Cookbook Name:: docker
# Provider:: container
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

require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut

def load_current_resource
  @current_resource = Chef::Resource::DockerContainer.new(new_resource)
  dps = shell_out("docker ps -a -notrunc")
  dps.stdout.each_line do |dps_line|
    next unless dps_line.include?(new_resource.image) && dps_line.include?(new_resource.command)
    container_ps = dps_line.split(%r{\s\s+})
    @current_resource.id(container_ps[0])
    @current_resource.running(true) if container_ps[4].include?("Up")
    break
  end
  @current_resource
end

action :remove do
  stop if @current_resource.id
  remove if @current_resource.id
  new_resource.updated_by_last_action(true)
end

action :restart do
  restart if @current_resource.id
  new_resource.updated_by_last_action(true)
end

action :run do
  unless running?
    run_args = ""
    run_args += " -d" if new_resource.detach
    run_args += " -e #{new_resource.env}" if new_resource.env
    run_args += " -h #{new_resource.hostname}" if new_resource.hostname
    run_args += " -m #{new_resource.memory}" if new_resource.memory
    run_args += " -p #{new_resource.port}" if new_resource.port
    run_args += " -t" if new_resource.tty
    run_args += " -u #{new_resource.user}" if new_resource.user
    run_args += " -v #{new_resource.volume}" if new_resource.volume
    dr = shell_out("docker run #{run_args} #{new_resource.image} #{new_resource.command}")
    new_resource.id(dr.stdout.chomp)
    new_resource.updated_by_last_action(true)
  end
end

action :start do
  start unless @current_resource.running
  new_resource.updated_by_last_action(true)
end

action :stop do
  stop if @current_resource.running
  new_resource.updated_by_last_action(true)
end

def remove
  shell_out("docker rm #{current_resource.id}")
end

def restart
  shell_out("docker restart #{current_resource.id}")
end

def running?
  @current_resource.running
end

def start
  shell_out("docker start #{current_resource.id}")
end

def stop
  shell_out("docker stop #{current_resource.id}")
end
