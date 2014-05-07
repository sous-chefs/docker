include_attribute 'golang'

# Installation/System attributes

default['docker']['arch'] =
  case node['kernel']['machine']
  when 'x86_64' then 'x86_64'
  # If Docker ever supports 32-bit or other architectures
  # when %r{i[3-6]86} then 'i386'
  else 'x86_64'
  end
default['docker']['group_members'] = []
default['docker']['init_type'] = value_for_platform(
  %w(amazon centos debian oracle redhat) => {
    'default' => 'sysv'
  },
  %w(fedora) => {
    'default' => 'systemd'
  },
  %w(ubuntu) => {
    'default' => 'upstart'
  },
  'default' => 'upstart'
)
default['docker']['install_type'] = value_for_platform(
  %w(amazon centos debian fedora redhat ubuntu) => {
    'default' => 'package'
  },
  'default' => 'binary'
)
default['docker']['install_dir'] =
  case node['docker']['install_type']
  when 'binary' then '/usr/local/bin'
  when 'source' then node['go']['gobin']
  else '/usr/bin'
  end
default['docker']['ipv4_forward'] = true
default['docker']['ipv6_forward'] = true
default['docker']['logfile'] = nil
default['docker']['version'] = nil

## Binary installation attributes

default['docker']['binary']['version'] = node['docker']['version'] || 'latest'
default['docker']['binary']['checksum'] =
case node['kernel']['name']
when 'Darwin'
  case node['docker']['binary']['version']
  when '0.10.0' then '416835b2e83e520c3c413b4b4e4ae34bca20704f085b435f4c200010dd1ac3b7'
  when '0.11.0' then '9db839b56a8656cfcef1f6543e9f75b01a774fdd6a50457da20d8183d6b415fa'
  end
when 'Linux'
  case node['docker']['binary']['version']
  when '0.10.0' then 'ce1f5bc88a99f8b2331614ede7199f872bd20e4ac1806de7332cbac8e441d1a0'
  when '0.11.0' then 'f80ba82acc0a6255960d3ff6fe145a8fdd0c07f136543fcd4676bb304daaf598'
  end
end
default['docker']['binary']['url'] = "http://get.docker.io/builds/#{node['kernel']['name']}/#{node['docker']['arch']}/docker-#{node['docker']['binary']['version']}"

## Package installation attributes

default['docker']['package']['action'] = 'install'
default['docker']['package']['distribution'] = 'docker'
default['docker']['package']['repo_url'] = value_for_platform(
  'debian' => {
    'default' => 'https://get.docker.io/ubuntu'
  },
  'ubuntu' => {
    %w(12.04 12.10 13.04 13.10) => 'https://get.docker.io/ubuntu',
    'default' => nil
  },
  'default' => nil
)
default['docker']['package']['repo_key'] = 'https://get.docker.io/gpg'

## Source installation attributes

default['docker']['source']['ref'] = 'master'
default['docker']['source']['url'] = 'https://github.com/dotcloud/docker.git'

# Docker Daemon attributes

default['docker']['api_enable_cors'] = nil

# DEPRECATED: will be removed in chef-docker 1.0
default['docker']['bind_socket'] = nil
# DEPRECATED: will be removed in chef-docker 1.0
default['docker']['bind_uri'] = nil

default['docker']['bip'] = nil
default['docker']['bridge'] = nil
default['docker']['debug'] = nil
default['docker']['dns'] = nil
default['docker']['dns_search'] = nil
default['docker']['exec_driver'] = nil

# DEPRECATED: will be removed in chef-docker 1.0
default['docker']['virtualization_type'] = node['docker']['exec_driver']

default['docker']['graph'] = nil
default['docker']['group'] = nil

# DEPRECATED: Support for bind_socket/bind_uri
default['docker']['host'] =
  if node['docker']['bind_socket'] || node['docker']['bind_uri']
    Array(node['docker']['bind_socket']) + Array(node['docker']['bind_uri'])
  else
    'unix:///var/run/docker.sock'
  end
default['docker']['http_proxy'] = nil
default['docker']['icc'] = nil
default['docker']['ip'] = nil
default['docker']['iptables'] = nil
default['docker']['mtu'] = nil
default['docker']['options'] = nil
default['docker']['pidfile'] = nil
default['docker']['ramdisk'] = false
default['docker']['storage_driver'] = nil

# DEPRECATED: will be removed in chef-docker 1.0
default['docker']['storage_type'] = node['docker']['storage_driver']

default['docker']['tls'] = nil
default['docker']['tlscacert'] = nil
default['docker']['tlscert'] = nil
default['docker']['tlskey'] = nil
default['docker']['tlsverify'] = nil
default['docker']['tmpdir'] = nil

# LWRP attributes

default['docker']['docker_daemon_timeout'] = 10

## docker_container attributes

default['docker']['container_cmd_timeout'] = 60
default['docker']['container_init_type'] = node['docker']['init_type']

## docker_image attributes

default['docker']['image_cmd_timeout'] = 300

## docker_registry attributes

default['docker']['registry_cmd_timeout'] = 60
