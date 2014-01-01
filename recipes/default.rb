case node['platform']
when 'oracle'
  include_recipe 'docker::cgroups'
  include_recipe 'docker::lxc'
when 'ubuntu'
  include_recipe 'apt'
  package 'apt-transport-https'
  package 'bsdtar'
  include_recipe 'docker::lxc' unless node['docker']['install_type'] == 'package'
  if Chef::VersionConstraint.new('< 13.10').include?(node['platform_version'])
    include_recipe 'docker::aufs'
  end
end

if node['docker']['install_type'] == 'source'
  include_recipe 'golang'
  include_recipe 'git'
end

include_recipe "docker::#{node['docker']['install_type']}"
include_recipe "docker::#{node['docker']['init_type']}"
