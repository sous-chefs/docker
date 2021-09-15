module DockerCookbook
  class DockerInstallationPackage < DockerBase
    resource_name :docker_installation_package
    provides :docker_installation_package

    property :setup_docker_repo, [true, false], default: true, desired_state: false
    property :repo_channel, String, default: 'stable'
    property :package_name, String, default: 'docker-ce', desired_state: false
    property :package_version, String, desired_state: false
    property :version, String, desired_state: false
    property :package_options, String, desired_state: false

    action :create do
      if new_resource.setup_docker_repo
        if platform_family?('rhel', 'fedora')
          arch = node['kernel']['machine']
          platform =
            if platform?('fedora')
              'fedora'
            # s390x is only available under rhel platform
            elsif platform?('redhat') && arch == 's390x'
              'rhel'
            else
              'centos'
            end

          yum_repository 'Docker' do
            baseurl "https://download.docker.com/linux/#{platform}/#{node['platform_version'].to_i}/#{arch}/#{new_resource.repo_channel}"
            gpgkey "https://download.docker.com/linux/#{platform}/gpg"
            description "Docker #{new_resource.repo_channel.capitalize} repository"
            gpgcheck true
            enabled true
          end
        elsif platform_family?('debian')
          deb_arch =
            case node['kernel']['machine']
            when 'x86_64'
              'amd64'
            when 'aarch64'
              'arm64'
            when 'armv7l'
              'armhf'
            when 'ppc64le'
              'ppc64el'
            else
              node['kernel']['machine']
            end

          package 'apt-transport-https'

          apt_repository 'Docker' do
            components Array(new_resource.repo_channel)
            uri "https://download.docker.com/linux/#{node['platform']}"
            arch deb_arch
            key "https://download.docker.com/linux/#{node['platform']}/gpg"
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
