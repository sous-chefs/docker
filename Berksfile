source 'https://supermarket.chef.io'

metadata

group :integration do
  cookbook 'apt'
  cookbook 'apt-docker', git: 'https://github.com/someara/cookbook-apt-docker', branch: 'chef13-warnings'
  cookbook 'yum-docker', git: 'https://github.com/someara/cookbook-yum-docker', branch: 'chef13-warnings'
  cookbook 'docker_test', path: 'test/cookbooks/docker_test'
  cookbook 'docker_service_test', path: 'test/cookbooks/docker_service_test'
  cookbook 'rspec_helper', path: 'test/cookbooks/rspec_helper'
end
