name 'docker'
maintainer 'Cookbook Engineering Team'
maintainer_email 'cookbooks@chef.io'
license 'Apache 2.0'
description 'Provides docker_service, docker_image, and docker_container resources'
version '2.13.7'

source_url 'https://github.com/chef-cookbooks/docker'
issues_url 'https://github.com/chef-cookbooks/docker/issues'

depends 'compat_resource', '>= 12.16.2'

supports 'amazon'
supports 'centos'
supports 'scientific'
supports 'oracle'
supports 'debian'
supports 'fedora'
supports 'redhat'
supports 'ubuntu'

chef_version '>= 12.1'
