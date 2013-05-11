#
# Cookbook Name:: docker
# Resource:: image
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

actions :pull, :remove

default_action :pull

attribute :image_name, :name_attribute => true
attribute :id, :kind_of => [String]
attribute :installed, :kind_of => [TrueClass, FalseClass]
attribute :installed_tag, :kind_of => [String]
attribute :registry, :kind_of => [String]
attribute :repository, :kind_of => [String]
attribute :tag, :kind_of => [String]
