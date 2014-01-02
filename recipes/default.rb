case node['platform']
when 'debian', 'ubuntu'
  include_recipe 'apt'
  package 'apt-transport-https'
  package 'bsdtar'
  include_recipe 'docker::lxc' unless node['docker']['install_type'] == 'package'
  if node['platform'] == 'debian'
    sysctl_param 'net.ipv4.ip_forward' do
      value 1
    end
  elsif node['platform'] == 'ubuntu' && Chef::VersionConstraint.new('< 13.10').include?(node['platform_version'])
    include_recipe 'docker::aufs'
  end
when 'oracle'
  include_recipe 'docker::cgroups'
  include_recipe 'docker::lxc'
end

if node['docker']['install_type'] == 'source'
  include_recipe 'golang'
  include_recipe 'git'
end

include_recipe "docker::#{node['docker']['install_type']}"
include_recipe "docker::#{node['docker']['init_type']}"
