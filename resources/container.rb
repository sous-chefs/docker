#
# Cookbook Name:: docker
# Resource:: container
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

actions :remove, :restart, :run, :start, :stop

default_action :run

attribute :image, :name_attribute => true
attribute :command, :kind_of => [String]
attribute :detach, :kind_of => [TrueClass, FalseClass]
attribute :env, :kind_of => [String]
attribute :hostname, :kind_of => [String]
attribute :id, :kind_of => [String]
attribute :memory, :kind_of => [Fixnum]
attribute :port, :kind_of => [Fixnum]
attribute :running, :kind_of => [TrueClass, FalseClass]
attribute :tty, :kind_of => [TrueClass, FalseClass]
attribute :user, :kind_of => [String]
attribute :volume, :kind_of => [String]
