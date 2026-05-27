# frozen_string_literal: true

name              'docker'
maintainer        'Sous Chefs'
maintainer_email  'help@sous-chefs.org'
license           'Apache-2.0'
description       'Provides docker_service, docker_image, and docker_container resources'
version           '12.0.0'
source_url        'https://github.com/sous-chefs/docker'
issues_url        'https://github.com/sous-chefs/docker/issues'
chef_version      '>= 16.0'

supports 'almalinux', '>= 9.0'
supports 'amazon', '>= 2023.0'
supports 'centos_stream', '>= 9.0'
supports 'debian', '>= 12.0'
supports 'fedora'
supports 'oracle', '>= 8.0'
supports 'redhat', '>= 8.0'
supports 'rocky', '>= 9.0'
supports 'ubuntu', '>= 22.04'

gem 'docker-api', '>= 2.3', '< 3'
