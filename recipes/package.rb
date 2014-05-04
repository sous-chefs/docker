
case node['platform']
when 'centos', 'redhat'
  include_recipe 'yum-epel'

  package 'docker-io' do
    version node['docker']['version']
    action node['docker']['package']['action'].intern
  end
when 'debian', 'ubuntu'
  if Helpers::Docker.use_docker_ppa? node
    p = 'lxc-docker'
    apt_repository 'docker' do
      uri node['docker']['package']['repo_url']
      distribution node['docker']['package']['distribution']
      components ['main']
      key node['docker']['package']['repo_key']
    end
  else
    p = 'docker.io'
    link '/usr/local/bin/docker' do
      action :nothing
      to '/usr/bin/docker.io'
    end
  end

  # reprepro doesn't support version tagging
  # See: https://github.com/dotcloud/docker/issues/979
  p += "-#{node['docker']['version']}" if node['docker']['version']

  package p do
    options '--force-yes -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"'
    action node['docker']['package']['action'].intern
    notifies :create, 'link[/usr/local/bin/docker]', :immediately unless Helpers::Docker.use_docker_ppa? node
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
