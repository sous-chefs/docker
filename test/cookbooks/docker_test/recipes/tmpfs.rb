def amazon?
  return true if node['platform'] == 'amazon'
  false
end

def precise?
  return true if node['platform'] == 'ubuntu' && node['platform_version'] == '12.04'
  false
end

def trusty?
  return true if node['platform'] == 'ubuntu' && node['platform_version'] == '14.04'
  return true if node['platform'] == 'linuxmint' && node['platform_version'] =~ /^17\.[0-9]$/
  false
end

if precise? || trusty? || amazon?
  mount '/var/run' do
    fstype 'tmpfs'
    device 'tmpfs'
    options 'rw,nosuid,nodev,noexec,relatime,size=1227540k'
    action [:mount, :enable]
  end
end
