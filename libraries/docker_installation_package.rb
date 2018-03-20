module DockerCookbook
  class DockerInstallationPackage < DockerBase
    # Resource properties
    resource_name :docker_installation_package

    provides :docker_installation, platform: 'amazon'

    property :setup_docker_repo, [TrueClass, FalseClass], default: lazy { platform?('amazon') ? false : true }, desired_state: false
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
            description "Docker #{new_resource.repo_channel.capitalize} repository"
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
        version new_resource.package_version unless amazon?
        options new_resource.package_options
        action :install
      end
    end

    action :delete do
      package new_resource.package_name do
        action :remove
      end
    end

    # These are helpers for the properties so they are not in an action class
    def default_docker_version
      '17.12.0'
    end

    def default_package_name
      return 'docker' if amazon?
      'docker-ce'
    end

    def el7?
      return true if node['platform_family'] == 'rhel' && node['platform_version'].to_i == 7
      false
    end

    def fedora?
      return true if node['platform'] == 'fedora'
      false
    end

    def debuntu?
      return true if node['platform_family'] == 'debian'
      false
    end

    def jessie?
      return true if node['platform'] == 'debian' && node['platform_version'].to_i == 8
      false
    end

    def stretch?
      return true if node['platform'] == 'debian' && node['platform_version'].to_i == 9
      false
    end

    def trusty?
      return true if node['platform'] == 'ubuntu' && node['platform_version'] == '14.04'
      false
    end

    def xenial?
      return true if node['platform'] == 'ubuntu' && node['platform_version'] == '16.04'
      false
    end

    def artful?
      return true if node['platform'] == 'ubuntu' && node['platform_version'] == '17.10'
      false
    end

    def bionic?
      return true if node['platform'] == 'ubuntu' && node['platform_version'] == '18.04'
      false
    end

    def amazon?
      return true if node['platform'] == 'amazon'
      false
    end

    # https://github.com/chef/chef/issues/4103
    def version_string(v)
      edition =  if debuntu?
                   '~ce'
                 elsif amazon?
                   'ce'
                 else
                   '.ce'
                 end

      codename = if Gem::Version.new(v) < Gem::Version.new('17.06.0')
                   if jessie?
                     '-jessie'
                   elsif stretch?
                     '-stretch'
                   elsif trusty?
                     '-trusty'
                   elsif xenial?
                     '-xenial'
                   elsif zesty?
                     '-zesty'
                   elsif artful?
                     '-artful'
                   elsif bionic?
                     '-bionic'
                   end
                 else
                   ''
                 end

      return "#{v}#{edition}-1.el7.centos" if el7?
      return "#{v}#{edition}" if fedora?
      return "#{v}#{edition}-0~debian#{codename}" if node['platform'] == 'debian'
      return "#{v}#{edition}-0~ubuntu#{codename}" if node['platform'] == 'ubuntu'
      v
    end
  end
end
