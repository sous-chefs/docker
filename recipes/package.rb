case node['platform']
when 'amazon', 'centos', 'redhat'
  include_recipe 'yum-epel'

  package 'docker-io' do
    version node['docker']['version']
    action node['docker']['package']['action'].intern
  end
when 'debian', 'ubuntu'
  apt_repository 'docker' do
    uri node['docker']['package']['repo_url']
    distribution node['docker']['package']['distribution']
    components ['main']
    key node['docker']['package']['repo_key']
  end

  # reprepro doesn't support version tagging
  # See: https://github.com/dotcloud/docker/issues/979
  p = 'lxc-docker'
  p += "-#{node['docker']['version']}" if node['docker']['version']

  package p do
    options '--force-yes -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"'
    action node['docker']['package']['action'].intern
  end
when 'fedora'
  package 'docker-io' do
    version node['docker']['version']
    action node['docker']['package']['action'].intern
  end
when 'max_os_x'
  homebrew_tap 'homebrew/binary'
  homebrew_package 'homebrew/binary/docker' do
    action node['docker']['package']['action'].intern
  end
end
