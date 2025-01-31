unified_mode true
use 'partial/_base'

provides :docker_installation, os: 'linux'
property :repo, %w(stable test), default: 'stable', desired_state: false

default_action :create

action :create do
  raise 'Installation script not supported on AlmaLinux or Rocky Linux' if platform?('almalinux', 'rocky')

  package 'curl' do
    options '--allowerasing'
    not_if { platform_family?('rhel') && shell_out('rpm -q curl-minimal').exitstatus.zero? }
  end

  execute 'download docker installation script' do
    command 'curl -fsSL https://get.docker.com -o /opt/install-docker.sh'
    creates '/opt/install-docker.sh'
  end

  execute 'install docker' do
    command "sh /opt/install-docker.sh --channel #{new_resource.repo}"
    creates '/usr/bin/docker'
  end
end

action :delete do
  package %w(docker-ce docker-engine) do
    action :remove
  end
end
