name 'docker'
maintainer 'Sean OMeara'
maintainer_email 'sean@chef.io'
license 'Apache 2.0'
description 'Provides docker_service, docker_image, and docker_container resources'
version '2.4.13'

source_url 'https://github.com/chef-cookbooks/docker'
issues_url 'https://github.com/chef-cookbooks/docker/issues'

depends 'compat_resource', '~> 12.7.1'

supports 'amazon'
supports 'centos'
supports 'debian'
supports 'fedora'
supports 'redhat'
supports 'ubuntu'
