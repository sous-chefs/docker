docker_installation_package 'default' do
  # Include epoch on RHEL to fix idempotency issues
  version platform_family?('rhel', 'fedora') ? '3:19.03.13' : '19.03.13'
  action :create
end
