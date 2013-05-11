#
# Cookbook Name:: docker
# Recipe:: aufs
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
  #
  # The below code copied from: https://github.com/thoward/docker-cookbook/blob/master/recipes/default.rb
  # It's not pretty, but gets the job done!
  #
  # If aufs isn't available, do our best to install the correct 
  # linux-image-extra package. This is somewhat messy because the
  # naming of these packages is very inconsistent across kernel
  # versions
  extra_package = %x(apt-cache search linux-image-extra-`uname -r | grep --only-matching -e [0-9]\.[0-9]\.[0-9]-[0-9]*` | cut -d " " -f 1).strip
  unless extra_package.empty?
    package extra_package do
      not_if "modprobe -l | grep aufs"
    end
  end

  modules "aufs" do
    action :load
  end
end
