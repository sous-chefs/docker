###################################################
# We're testing Docker by running it inside Docker.
# This leads to strange behavior when using various
# storage drivers.
#
# To hack around this, we mount a tmpfs in various
# locations so the filesystem looks "fresh".
###################################################

def precise?
  return true if node['platform'] == 'ubuntu' && node['platform_version'] == '12.04'
  false
end

def trusty?
  return true if node['platform'] == 'ubuntu' && node['platform_version'] == '14.04'
  return true if node['platform'] == 'linuxmint' && node['platform_version'] =~ /^17\.[0-9]$/
  false
end

if precise? || trusty?
  mount '/var/run' do
    fstype 'tmpfs'
    device 'tmpfs'
    options 'rw,nosuid,nodev,noexec,relatime,size=1227540k'
    action [:mount, :enable]
  end
end

%w( docker docker-one docker-two ).each do |dir|
  directory "/var/lib/#{dir}" do
    action :create
  end

  mount "/var/lib/#{dir}" do
    fstype 'tmpfs'
    device 'tmpfs'
    options 'rw,nosuid,nodev,noexec,relatime,size=0'
    action [:mount, :enable]
  end
end
