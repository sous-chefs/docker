docker_installation_package 'default' do
  # Include epoch on RHEL to fix idempotency issues
  version platform_family?('rhel', 'fedora') ? '3:20.10.1' : '20.10.1'
  action :create
end
