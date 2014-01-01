include_attribute 'golang'

case node['kernel']['machine']
when 'x86_64'
  default['docker']['arch'] = 'x86_64'
# If Docker ever supports 32-bit or other architectures
# when %r{i[3-6]86}
#   default['docker']['arch'] = "i386"
else
  default['docker']['arch'] = 'x86_64'
end

default['docker']['bind_socket'] = 'unix:///var/run/docker.sock'
default['docker']['bind_uri'] = nil
default['docker']['container_cmd_timeout'] = 60
default['docker']['http_proxy'] = nil
default['docker']['image_cmd_timeout'] = 300

case node['platform']
when 'centos', 'redhat'
  default['docker']['init_type'] = 'sysv'
when 'fedora'
  default['docker']['init_type'] = 'systemd'
when 'ubuntu'
  default['docker']['init_type'] = 'upstart'
else
  default['docker']['init_type'] = 'upstart'
end

default['docker']['container_init_type'] = node['docker']['init_type']

case node['platform']
when 'centos', 'fedora', 'redhat', 'ubuntu'
  default['docker']['install_type'] = 'package'
else
  default['docker']['install_type'] = 'binary'
end

case node['docker']['install_type']
when 'binary'
  default['docker']['install_dir'] = '/usr/local/bin'
when 'source'
  default['docker']['install_dir'] = node['go']['gobin']
else
  default['docker']['install_dir'] = '/usr/bin'
end

default['docker']['version'] = nil

# Binary attributes
default['docker']['binary']['version'] = node['docker']['version'] || 'latest'
default['docker']['binary']['url'] = "http://get.docker.io/builds/Linux/#{node['docker']['arch']}/docker-#{node['docker']['binary']['version']}"

# Package attributes
case node['platform']
when 'ubuntu'
  default['docker']['package']['distribution'] = 'docker'
  default['docker']['package']['repo_url'] = 'https://get.docker.io/ubuntu'
  default['docker']['package']['repo_key'] = 'https://get.docker.io/gpg'
end

default['docker']['package']['action'] = 'install'

# Source attributes
default['docker']['source']['ref'] = 'master'
default['docker']['source']['url'] = 'https://github.com/dotcloud/docker.git'
