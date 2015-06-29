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
  %w(amazon debian oracle) => {
    'default' => 'sysv'
  },
  %w(redhat centos) => {
    %w(6.0 6.1 6.2 6.3 6.4 6.5 6.6) => 'sysv',
    'default' => 'systemd'
  },
  %w(fedora) => {
    'default' => 'systemd'
  },
  %w(ubuntu) => {
    %w(15.04) => 'systemd',
    'default' => 'upstart'
  },
  'default' => 'upstart'
)
default['docker']['install_type'] = value_for_platform(
  %w(centos debian fedora mac_os_x redhat ubuntu amazon) => {
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

# Actions: :warn, :fatal
default['docker']['alert_on_error_action'] = :fatal

## Binary installation attributes

default['docker']['binary']['dependency_packages'] = value_for_platform_family(
  'debian' => %w(procps xz-utils),
  'rhel' => %w(procps xz),
  'default' => %w()
)
default['docker']['binary']['version'] = node['docker']['version'] || 'latest'
default['docker']['binary']['checksum'] =
case node['kernel']['name']
when 'Darwin'
  case node['docker']['binary']['version']
  when '0.10.0' then '416835b2e83e520c3c413b4b4e4ae34bca20704f085b435f4c200010dd1ac3b7'
  when '0.11.0' then '9db839b56a8656cfcef1f6543e9f75b01a774fdd6a50457da20d8183d6b415fa'
  when '0.11.1' then '386ffa26e52856107efb0b3075625d5b2331fa5acc8965fef87c1ab7d900c4e9'
  when '0.12.0' then 'a38dccb7f544fad4ef2f95243bef7e2c9afbd76de0e4547b61b27698bf9065f3'
  when '1.0.0' then '67c3c9f285584533ac365a56515f606fc91d4dcd0bfa69c2f159eeb5e37ea3b8'
  when '1.0.1' then 'b662e7718f0a8e23d2e819470a368f257e2bc46f76417712360de7def775e9d4'
  end
when 'Linux'
  case node['docker']['binary']['version']
  when '0.10.0' then 'ce1f5bc88a99f8b2331614ede7199f872bd20e4ac1806de7332cbac8e441d1a0'
  when '0.11.0' then 'f80ba82acc0a6255960d3ff6fe145a8fdd0c07f136543fcd4676bb304daaf598'
  when '0.11.1' then 'ed2f2437fd6b9af69484db152d65c0b025aa55aae6e0991de92d9efa2511a7a3'
  when '0.12.0' then '0f611f7031642a60716e132a6c39ec52479e927dfbda550973e1574640135313'
  when '1.0.0' then '55cf74ea4c65fe36e9b47ca112218459cc905ede687ebfde21b2ba91c707db94'
  when '1.0.1' then '1d9aea20ec8e640ec9feb6757819ce01ca4d007f208979e3156ed687b809a75b'
  end
end
default['docker']['binary']['url'] = "http://get.docker.io/builds/#{node['kernel']['name']}/#{node['docker']['arch']}/docker-#{node['docker']['binary']['version']}"

## Package installation attributes

default['docker']['package']['action'] = 'install'
default['docker']['package']['distribution'] = 'docker'
default['docker']['package']['name'] = value_for_platform(
  'amazon' => {
    'default' => 'docker'
  },
  %w(centos redhat) => {
    %w(6.0 6.1 6.2 6.3 6.4 6.5 6.6) => 'docker-io',
    'default' => 'docker'
  },
  'fedora' => {
    'default' => 'docker-io'
  },
  'debian' => {
    'default' => 'lxc-docker'
  },
  'mac_os_x' => {
    'default' => 'homebrew/binary/docker'
  },
  'ubuntu' => {
    %w(12.04 12.10 13.04 13.10 14.04 14.10 15.04) => 'lxc-docker',
    'default' => 'docker.io'
  },
  'default' => nil
)
default['docker']['package']['repo_url'] = value_for_platform(
  'debian' => {
    'default' => 'https://get.docker.io/ubuntu'
  },
  'ubuntu' => {
    %w(12.04 12.10 13.04 13.10 14.04 14.10 15.04) => 'https://get.docker.io/ubuntu',
    'default' => nil
  },
  'default' => nil
)
default['docker']['package']['repo_keyserver'] = 'hkp://keyserver.ubuntu.com:80'
# Found at https://get.docker.io/ubuntu/
default['docker']['package']['repo_key'] = 'A88D21E9'

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
default['docker']['group'] = node['docker']['group_members'].empty? ? nil : 'docker'

# DEPRECATED: Support for bind_socket/bind_uri
default['docker']['host'] =
  if node['docker']['bind_socket'] || node['docker']['bind_uri']
    Array(node['docker']['bind_socket']) + Array(node['docker']['bind_uri'])
  elsif node['docker']['init_type'] == 'systemd'
    'fd://'
  else
    'unix:///var/run/docker.sock'
  end
default['docker']['http_proxy'] = nil
default['docker']['icc'] = nil
default['docker']['insecure-registry'] = nil
default['docker']['ip'] = nil
default['docker']['iptables'] = nil
default['docker']['mtu'] = nil
default['docker']['no_proxy'] = nil
default['docker']['options'] = nil
default['docker']['pidfile'] = nil
default['docker']['ramdisk'] = false
default['docker']['registry-mirror'] = nil
default['docker']['selinux_enabled'] = nil
default['docker']['storage_driver'] = nil
default['docker']['storage_opt'] = nil

# the systemd system dir is different in newer Ubuntu (and debian?)
default['docker']['systemd_system_dir'] = value_for_platform(
  'ubuntu' => {
    %w(15.04) => '/lib/systemd/system',
    'default' => '/usr/lib/systemd/system'
  },
  'default' => '/usr/lib/systemd/system'
)

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

# Other attributes

# DEPRECATED: will be removed in chef-docker 1.0
default['docker']['restart'] = nil
