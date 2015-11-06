name 'docker'
maintainer 'Sean OMeara'
maintainer_email 'sean@chef.io'
license 'Apache 2.0'
description 'Provides docker_service, docker_image, and docker_container resources'
version '2.2.4'

source_url 'https://github.com/someara/chef-docker'
issues_url 'https://github.com/someara/chef-docker/issues'

depends 'compat_resource'

supports 'amazon'
supports 'centos'
supports 'debian'
supports 'fedora'
supports 'redhat'
supports 'ubuntu'
