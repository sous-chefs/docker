include_attribute 'golang'

default['docker']['arch'] =
  case node['kernel']['machine']
  when 'x86_64' then 'x86_64'
  # If Docker ever supports 32-bit or other architectures
  # when %r{i[3-6]86} then 'i386'
  else 'x86_64'
  end

default['docker']['bind_socket'] = 'unix:///var/run/docker.sock'
default['docker']['bind_uri'] = nil
default['docker']['container_cmd_timeout'] = 60
default['docker']['container_dns'] = nil
default['docker']['container_dns_search'] = nil
default['docker']['docker_daemon_timeout'] = 10
default['docker']['exec_driver'] = nil

# DEPRECATED: will be removed in chef-docker 1.0
default['docker']['virtualization_type'] = node['docker']['exec_driver']

default['docker']['group'] = nil
default['docker']['group_members'] = []
default['docker']['http_proxy'] = nil
default['docker']['image_cmd_timeout'] = 300
default['docker']['logfile'] = nil
default['docker']['options'] = nil
default['docker']['pidfile'] = nil
default['docker']['ramdisk'] = false
default['docker']['registry_cmd_timeout'] = 60
default['docker']['tmpdir'] = nil

default['docker']['init_type'] = value_for_platform(
  %w(centos debian oracle redhat) => {
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

default['docker']['container_init_type'] = node['docker']['init_type']

default['docker']['install_type'] = value_for_platform(
  %w(centos debian fedora redhat ubuntu) => {
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

default['docker']['storage_driver'] = value_for_platform(
  %w(centos fedora oracle redhat) => {
    'default' => 'devicemapper'
  },
  %w(debian ubuntu) => {
    'default' => 'aufs'
  },
  'default' => nil
)
# DEPRECATED: will be removed in chef-docker 1.0
default['docker']['storage_type'] = node['docker']['storage_driver']

default['docker']['version'] = nil

# Binary attributes
default['docker']['binary']['version'] = node['docker']['version'] || 'latest'
default['docker']['binary']['url'] = "http://get.docker.io/builds/#{node['kernel']['name']}/#{node['docker']['arch']}/docker-#{node['docker']['binary']['version']}"

# Package attributes
case node['platform']
when 'debian', 'ubuntu'
  default['docker']['package']['distribution'] = 'docker'
  default['docker']['package']['repo_url'] = 'https://get.docker.io/ubuntu'
  default['docker']['package']['repo_key'] = 'https://get.docker.io/gpg'
end

default['docker']['package']['action'] = 'install'

# Source attributes
default['docker']['source']['ref'] = 'master'
default['docker']['source']['url'] = 'https://github.com/dotcloud/docker.git'
