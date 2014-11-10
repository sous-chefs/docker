::Chef::Recipe.send(:include, Docker::Helpers)

action = node['docker']['alert_on_error_action']

case node['platform_family']
when 'mac_os_x'
  # Is VirtualBox Installed?
  vbox_exists = binary_installed?('VboxManage')
  vbox_in_runlist = node.has_recipe?('virtualbox')

  unless vbox_exists || vbox_in_runlist
    alert_on_error DockerCookbook::Exceptions::MissingDependency, action, <<-MSG
VirtualBox is a requirement for running Docker on Mac OS X and it was not found on your system or
in your chef-client's run_list. To successfully install Docker on Mac OS X we recommend adding the
following cookbooks to your run_list.

1) virtualbox   - http://community.opscode.com/cookbooks/virtualbox
2) boot2docker  - https://github.com/bflad/chef-boot2docker
    MSG
  end

  # Is boot2docker installed?
  boot2docker_exists = binary_installed?('boot2docker')
  boot2docker_in_runlist = node.has_recipe?('boot2docker')
  unless boot2docker_exists || boot2docker_in_runlist
    alert_on_error DockerCookbook::Exceptions::MissingDependency, action, <<-MSG
boot2docker is a requirement for running Docker on Mac OS X and it was not found on your system or
in your chef-client's run_list. To successfully install Docker on Mac OS X we recommend adding the
following cookbooks prior to docker in your run_list.

1) virtualbox   - http://community.opscode.com/cookbooks/virtualbox
2) boot2docker  - https://github.com/bflad/chef-boot2docker
    MSG
  end

when 'debian'
  # check kernel.release >= 3.8
  unless ::Chef::VersionConstraint.new('>= 3.8').include?(node['kernel']['release'].match(/\d+.\d+/)[0])
    alert_on_error DockerCookbook::Exceptions::InvalidKernelVersion, action, <<-MSG
Due to a bug in LXC, Docker works best on the 3.8 Linux kernel. You are currently running #{node['kernel']['release']}.
It is recommended that you upgrade your kernel to at least 3.8.

More Info: http://docs.docker.io/installation/ubuntulinux/
    MSG
  end

when 'rhel'
  # check kernel.machine == x86_64
  unless node['kernel']['machine'] == 'x86_64'
    alert_on_error DockerCookbook::Exceptions::InvalidArchitecture, action, <<-MSG
Due to current Docker limitations, Docker is only able to run on 64bit architectures.
More Info: http://docs.docker.io/installation/rhel/
    MSG
  end

  # check platform_version >= 6.5
  unless ::Chef::VersionConstraint.new('>= 6.5').include?(node['platform_version'])
    alert_on_error DockerCookbook::Exceptions::InvalidPlatformVersion, action, <<-MSG
Docker requires RHEL 6.5 or greater, with RHEL6 kernel version 2.6.32-431 or higher.
More Info: http://docs.docker.io/installation/rhel/
    MSG
  end

  case node['docker']['install_type']
  when 'binary'
    unless ::Chef::VersionConstraint.new('>= 3.8').include?(node['kernel']['release'].match(/\d+.\d+.\d+/)[0])
      alert_on_error DockerCookbook::Exceptions::InvalidKernelVersion, action, <<-MSG
Binary installations on the RHEL 6.5 family with a kernel < 3.8 are highly unstable. You are currently running RHEL #{node['platform']['version']} on kernel #{node['kernel']['release']}.
It is recommended that you install Docker on RHEL 6.5 machines using the package method or as a Binary with a kernel >= 3.8.

To do this, please set `node['docker']['install_type']` to 'package' in the appropriate location.
      MSG
    end
  end

  # check kernel.release > 2.6.32-431
  unless ::Chef::VersionConstraint.new('>= 2.6.32').include?(node['kernel']['release'].match(/\d+.\d+.\d+/)[0])
    alert_on_error DockerCookbook::Exceptions::InvalidKernelVersion, action, <<-MSG
Docker requires RHEL6 kernel version 2.6.32-431 or higher.
More Info: http://docs.docker.io/installation/rhel/
    MSG
  end

when 'fedora'
  if node['docker']['install_type'] == 'binary' && node['docker']['exec_driver'] == 'lxc'
    alert_on_error DockerCookbook::Exceptions::InvalidPlatformVersion, action, <<-MSG
LXC on Fedora is incredibly unstable. It is recommended to use native Docker on Fedora.
    MSG
  end

when 'suse'
  # check kernel.relase >= 3.8 (maybe??)
  # check kernel.machine == x86_64
  unless node['kernel']['machine'] == 'x86_64'
    alert_on_error DockerCookbook::Exceptions::InvalidArchitecture, action, <<-MSG
Due to current Docker limitations, Docker is only able to run on 64bit architectures.
More Info: http://docs.docker.io/installation/openSUSE/
    MSG
  end
end
