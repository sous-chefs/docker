source 'https://supermarket.chef.io'

metadata

group :integration do
  cookbook 'apt'
  cookbook 'apt-docker'
  cookbook 'yum-docker', git: 'https://github.com/someara/cookbook-yum-docker', branch: 'amazon'
  cookbook 'docker_test', path: 'test/cookbooks/docker_test'
  cookbook 'rspec_helper', path: 'test/cookbooks/rspec_helper'
end
