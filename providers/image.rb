#
# Cookbook Name:: docker
# Provider:: image
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
  @current_resource = Chef::Resource::DockerImage.new(new_resource)
  di = shell_out("docker images -a")
  if di.stdout.include?(new_resource.image_name)
    di.stdout.each_line do |di_line|
      next unless di_line.include?(new_resource.image_name)
      image_info = di_line.split(%r{\s\s+})
      @current_resource.installed(true)
      @current_resource.repository(image_info[0])
      @current_resource.installed_tag(image_info[1])
      @current_resource.id(image_info[2])
      break
    end
  end
  @current_resource
end

action :pull do
  unless installed?
    pull_args = ""
    pull_args += " -registry #{new_resource.registry}" if new_resource.registry
    pull_args += " -t #{new_resource.tag}" if new_resource.tag
    shell_out("docker pull #{new_resource.image_name} #{pull_args}")
    new_resource.updated_by_last_action(true)
  end
end

action :remove do
  remove if @current_resource.installed
  new_resource.updated_by_last_action(true)
end

def remove
  shell_out("docker rmi #{new_resource.image_name}")
end

def installed?
  @current_resource.installed && tag_match
end

def tag_match
  # if the tag is specified, we need to check if it matches what
  # is installed already
  if new_resource.tag
    @current_resource.installed_tag == new_resource.tag
  else
    # the tag matches otherwise because it's installed
    true
  end
end
