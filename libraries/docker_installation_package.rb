module DockerCookbook
  class DockerInstallationPackage < DockerBase
    require_relative 'helpers_installation_package'

    include DockerHelpers::InstallationPackage

    # Resource properties
    resource_name :docker_installation_package

    provides :docker_installation, platform: 'amazon'

    property :setup_docker_repo, [true, false], default: lazy { platform?('amazon') ? false : true }, desired_state: false
    property :repo_channel, String, default: 'stable'
    property :package_name, String, default: lazy { default_package_name }, desired_state: false
    property :package_version, String, default: lazy { version_string(version) }, desired_state: false
    property :version, String, default: lazy { default_docker_version }, desired_state: false
    property :package_options, String, desired_state: false

    # Actions
    action :create do
      if new_resource.setup_docker_repo
        if platform_family?('rhel', 'fedora')
          platform = platform?('fedora') ? 'fedora' : 'centos'

          yum_repository 'Docker' do
            baseurl "https://download.docker.com/linux/#{platform}/#{node['platform_version'].to_i}/x86_64/#{new_resource.repo_channel}"
            gpgkey "https://download.docker.com/linux/#{platform}/gpg"
            description "Docker #{new_resource.repo_channel.capitalize} Respository"
            gpgcheck true
            enabled true
          end
        elsif platform_family?('debian')
          apt_repository 'Docker' do
            components Array(new_resource.repo_channel)
            uri "https://download.docker.com/linux/#{node['platform']}"
            arch 'amd64'
            keyserver 'keyserver.ubuntu.com'
            key '9DC858229FC7DD38854AE2D88D81803C0EBFCD88'
            action :add
          end
        else
          Chef::Log.warn("Cannot setup the Docker repo for platform #{node['platform']}. Skipping.")
        end
      end

      package new_resource.package_name do
        version new_resource.package_version
        options new_resource.package_options
        action :install
      end
    end

    action :delete do
      package new_resource.package_name do
        action :remove
      end
    end
  end
end
