name 'docker'
maintainer 'Sean OMeara'
maintainer_email 'sean@chef.io'
license 'Apache 2.0'
description 'Provides docker_service, docker_image, and docker_container resources'
version '2.5.8'

source_url 'https://github.com/chef-cookbooks/docker'
issues_url 'https://github.com/chef-cookbooks/docker/issues'

depends 'compat_resource', '~> 12.8.0'

supports 'amazon'
supports 'centos'
supports 'debian'
supports 'fedora'
supports 'redhat'
supports 'ubuntu'
