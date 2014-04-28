::Chef::Recipe.send(:include, Helpers)

case node['platform']
when 'mac_os_x', 'mac_os_x_server'
  # Is VirtualBox Installed?
  vbox_exists = binary_installed?('VboxManage')
  vbox_in_runlist = node.has_recipe?('virtualbox')

  unless vbox_exists || vbox_in_runlist
    fail DockerCookbook::Exceptions::MissingDependency, <<-MSG1
VirtualBox is a requirement for running Docker on Mac OS X and it was not found on your system or
in your chef-client's run_list. To successfully install Docker on Mac OS X we recommend adding the 
following cookbooks to your run_list. 

1) virtualbox   - http://community.opscode.com/cookbooks/virtualbox
2) boot2docker  - https://github.com/bflad/chef-boot2docker
    MSG1
  end

  # Is boot2docker installed?
  boot2docker_exists = binary_installed?('boot2docker')
  boot2docker_in_runlist = node.has_recipe?('boot2docker')
  unless boot2docker_exists || boot2docker_in_runlist

    fail DockerCookbook::Exceptions::MissingDependency, <<-MSG2
boot2docker is a requirement for running Docker on Mac OS X and it was not found on your system or
in your chef-client's run_list. To successfully install Docker on Mac OS X we recommend adding the 
following cookbooks prior to docker in your run_list.

1) virtualbox   - http://community.opscode.com/cookbooks/virtualbox
2) boot2docker  - https://github.com/bflad/chef-boot2docker
    MSG2
  end

when 'ubuntu'
  # check kernel.release >= 3.8
  unless ::Chef::VersionConstraint.new('>= 3.8').include?(node['kernel']['release'].match(/\d+.\d+.\d+/)[0])
    fail DockerCookbook::Exceptions::InvalidKernelVersion, <<-MSG3
Due to a bug in LXC, Docker works best on the 3.8 Linux kernel. You are currently running #{node['kernel']['release']}.
It is recommended that you upgrade your kernel to at least 3.8, otherwise you may experience unexpected behavior
from Docker.

More Info: http://docs.docker.io/installation/ubuntulinux/
    MSG3
  end

when 'redhat'
  # check kernel.machine == x86_64
  unless node['kernel']['machine'] == 'x86_64'
    fail DockerCookbook::Exceptions::InvalidArchitecture, <<-MSG4
Due to current Docker limitations, Docker is only able to run on 64bit architectures. 
More Info: http://docs.docker.io/installation/rhel/
    MSG4
  end

  # check platform_version >= 6.5
  unless ::Chef::VersionConstraint.new('>= 6.5').include?(node['platform_version'])
    fail DockerCookbook::Exceptions::InvalidPlatformVersion, <<-MSG5
Docker requires RHEL 6.5 or greater, with RHEL6 kernel version 2.6.32-431 or higher.
More Info: http://docs.docker.io/installation/rhel/
    MSG5
  end

  # check kernel.release > 2.6.32-431
  unless ::Chef::VersionConstraint.new('>= 2.6.32').include?(node['kernel']['release'].match(/\d+.\d+.\d+/)[0])
    fail DockerCookbook::Exceptions::InvalidKernelVersion, <<-MSG6
Docker requires RHEL 6.5 or greater, with RHEL6 kernel version 2.6.32-431 or higher.
More Info: http://docs.docker.io/installation/rhel/
    MSG6
  end

when 'suse'
  # check kernel.relase >= 3.8 (maybe??)
  # check kernel.machine == x86_64
  unless node['kernel']['machine'] == 'x86_64'
    fail DockerCookbook::Exceptions::InvalidArchitecture, <<-MSG7
Due to current Docker limitations, Docker is only able to run on 64bit architectures. 
More Info: http://docs.docker.io/installation/openSUSE/
    MSG7
  end
end


