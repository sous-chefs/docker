# TODO: Platforms handled here should be fixed in lxc cookbook
# Currently: https://github.com/hw-cookbooks/lxc/
case node['platform']
when 'debian', 'fedora', 'oracle'
  package 'lxc'
when 'ubuntu'

  #
  # This is a workaround to address bflad/chef-docker#188. In the absence of an
  # upstream solution we are manually upgrading libcgmanager to avoid lxc/lxc#247.
  # In this future this issue should be addressed formally in the hw-cookbooks/lxc
  # cookbook.
  #
  package 'libcgmanager0' do
    action :upgrade
    only_if { node['platform_version'] == '14.04' }
  end

  include_recipe 'lxc'

  #
  # This is a workaround to address docker/docker#2702 which prevents containers
  # from properly starting when using LXC on some Ubuntu machines. Right now we
  # have only seen it on Ubuntu 14.10.
  #
  package 'apparmor-utils' do
    action :install
    only_if { node['platform_version'] == '14.10' }
    notifies :run, 'execute[aa-complain]', :immediately
  end

  execute 'aa-complain' do
    command 'aa-complain /usr/bin/lxc-start'
    action :nothing
  end
end
