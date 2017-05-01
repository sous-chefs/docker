name 'docker'
maintainer 'Cookbook Engineering Team'
maintainer_email 'cookbooks@chef.io'
license 'Apache-2.0'
description 'Provides docker_service, docker_image, and docker_container resources'
version '2.15.6'

source_url 'https://github.com/chef-cookbooks/docker'
issues_url 'https://github.com/chef-cookbooks/docker/issues'

supports 'amazon'
supports 'centos'
supports 'scientific'
supports 'oracle'
supports 'debian'
supports 'fedora'
supports 'redhat'
supports 'ubuntu'

chef_version '>= 12.5' if respond_to?(:chef_version)
