name 'docker'
maintainer 'Brian Flad'
maintainer_email 'bflad417@gmail.com'
license 'Apache 2.0'
description 'Installs/Configures Docker'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.0.49'

source_url 'https://github.com/bflad/chef-docker'
issues_url 'https://github.com/bflad/chef-docker/issues'

depends 'compat_resource'

supports 'amazon'
supports 'centos'
supports 'debian'
supports 'fedora'
supports 'redhat'
supports 'ubuntu'
