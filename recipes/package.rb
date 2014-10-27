p = node['docker']['package']['name']

case node['platform']
when 'amazon', 'centos', 'fedora', 'redhat'
  include_recipe 'yum-epel' if %w(centos redhat).include?(node['platform'])

  package p do
    version node['docker']['version']
    action node['docker']['package']['action'].intern
  end
when 'debian', 'ubuntu'
  if Docker::Helpers.using_docker_io_package? node
    link '/usr/local/bin/docker' do
      to '/usr/bin/docker.io'
    end
  else
    apt_repository 'docker' do
      uri node['docker']['package']['repo_url']
      distribution node['docker']['package']['distribution']
      components ['main']
      keyserver node['docker']['package']['repo_keyserver']
      key node['docker']['package']['repo_key']
    end
  end

  # reprepro doesn't support version tagging
  # See: https://github.com/dotcloud/docker/issues/979
  p += "-#{node['docker']['version']}" if node['docker']['version']

  package p do
    options '--force-yes -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"'
    action node['docker']['package']['action'].intern
  end
when 'mac_os_x', 'mac_os_x_server'
  homebrew_tap 'homebrew/binary'
  package p do
    action node['docker']['package']['action'].intern
  end
else
  fail "The package installation method for `#{node['platform']} is not supported.`"
end
