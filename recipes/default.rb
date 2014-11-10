include_recipe 'docker::dep_check'

log 'breaking_changes_alert' do
  message <<-MSG

#{'*' * 60}
*
* WARNING!
* BREAKING CHANGE COMING TO DOCKER COOKBOOK IN VERSION 1.0
*
#{'*' * 60}

To avoid any issues, please make sure to pin your versions in the appropriate places.
  - metadata.rb
  - Chef Environments
  - Berksfile
  - Policyfile

Please check out https://github.com/bflad/chef-docker for more details.

  MSG
end

case node['platform']
when 'debian', 'ubuntu'
  include_recipe 'apt'
  package 'apt-transport-https'
  package 'bsdtar'
  if node['platform'] == 'debian'
    include_recipe 'sysctl'
    sysctl_param 'net.ipv4.ip_forward' do
      value 1
      only_if { node['docker']['ipv4_forward'] }
    end
    sysctl_param 'net.ipv6.conf.all.forwarding' do
      value 1
      only_if { node['docker']['ipv6_forward'] }
    end
  end
end

if node['docker']['exec_driver'] == 'lxc'
  include_recipe 'docker::cgroups'
  include_recipe 'docker::lxc'
end

directory 'docker-graph' do
  path node['docker']['graph']
  not_if { node['docker']['graph'].nil? }
end

unless node['docker']['install_type'] == 'package'
  if node['platform'] == 'ubuntu' && Chef::VersionConstraint.new('< 13.10').include?(node['platform_version'])
    include_recipe "docker::#{node['docker']['storage_driver']}" if node['docker']['storage_driver']
  end
  if node['docker']['install_type'] == 'binary'
    include_recipe 'git'
    include_recipe 'iptables'

    node['docker']['binary']['dependency_packages'].each do |p|
      package p
    end

    # cgroupfs
    # https://github.com/tianon/cgroupfs-mount/blob/master/cgroupfs-mount
    template "#{node['docker']['install_dir']}/cgroupfs-mount" do
      source 'cgroupfs-mount.erb'
      owner 'root'
      group 'root'
      mode '0755'
    end

    execute 'cgroupfs-mount' do
      command "#{node['docker']['install_dir']}/cgroupfs-mount"
      not_if 'mountpoint -q /sys/fs/cgroup'
    end
  elsif node['docker']['install_type'] == 'source'
    include_recipe 'git'
    include_recipe 'golang'
  end
end

include_recipe "docker::#{node['docker']['install_type']}"
include_recipe 'docker::group' unless node['docker']['group_members'].empty?
include_recipe "docker::#{node['docker']['init_type']}"
