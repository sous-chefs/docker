docker_installation_package 'default' do
  version '19.03.8' unless platform_family?('fedora') # Fedora doesn't have this version
  action :create
end
