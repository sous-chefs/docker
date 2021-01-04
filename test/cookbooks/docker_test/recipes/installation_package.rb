docker_ver =
  # Include epoch on RHEL to fix idempotency issues
  if platform_family?('rhel', 'fedora')
    '3:20.10.1'
  # Debian 9 does not include 20.10
  elsif platform?('debian') && node['platform_version'].to_i == 9
    '19.03.14'
  else
    '20.10.1'
  end

docker_installation_package 'default' do
  version docker_ver
  action :create
end
