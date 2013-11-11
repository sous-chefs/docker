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
default['docker']['http_proxy'] = nil
default['docker']['install_type'] = 'package'

case node['docker']['install_type']
when 'binary'
  default['docker']['install_dir'] = '/usr/local/bin'
when 'source'
  default['docker']['install_dir'] = node['go']['gobin']
else
  default['docker']['install_dir'] = '/usr/bin'
end

# Binary attributes
default['docker']['binary']['version'] = 'latest'
default['docker']['binary']['url'] = "http://get.docker.io/builds/Linux/#{node['docker']['arch']}/docker-#{node['docker']['binary']['version']}"

# Package attributes
case node['platform']
when 'ubuntu'
  default['docker']['package']['distribution'] = 'docker'
  default['docker']['package']['repo_url'] = 'https://get.docker.io/ubuntu'
  default['docker']['package']['repo_key'] = 'https://get.docker.io/gpg'
end

# Source attributes
default['docker']['source']['ref'] = 'master'
default['docker']['source']['url'] = 'https://github.com/dotcloud/docker.git'
