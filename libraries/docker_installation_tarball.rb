module DockerCookbook
  class DockerInstallationTarball < DockerBase
    resource_name :docker_installation_tarball
    provides :docker_installation_tarball

    property :checksum, String, default: lazy { default_checksum }, desired_state: false
    property :source, String, default: lazy { default_source }, desired_state: false
    property :channel, String, default: 'stable', desired_state: false
    property :version, String, default: '19.03.13', desired_state: false

    ##################
    # Property Helpers
    ##################

    def docker_kernel
      node['kernel']['name']
    end

    def docker_arch
      node['kernel']['machine']
    end

    def default_source
      "https://download.docker.com/#{docker_kernel.downcase}/static/#{channel}/#{docker_arch}/#{default_filename(version)}"
    end

    def default_filename(version)
      # https://download.docker.com/linux/static/stable/x86_64/
      regex = /^(?<major>\d*)\.(?<minor>\d*)\./
      semver = regex.match(version)
      if semver['major'].to_i >= 19
        "docker-#{version}.tgz"
      elsif semver['major'].to_i == 18 && semver['minor'].to_i > 6
        "docker-#{version}.tgz"
      else
        "docker-#{version}-ce.tgz"
      end
    end

    def default_checksum
      case docker_kernel
      when 'Darwin'
        case version
        when '18.03.1' then 'bbfb9c599a4fdb45523496c2ead191056ff43d6be90cf0e348421dd56bc3dcf0'
        when '18.06.3' then 'f7347ef27db9a438b05b8f82cd4c017af5693fe26202d9b3babf750df3e05e0c'
        when '18.09.9' then 'ed83a3d51fef2bbcdb19d091ff0690a233aed4bbb47d2f7860d377196e0143a0'
        when '19.03.13' then 'd035d468218c26973710b35101b55dcf82c25d43a0a88aaa9f667b1782ec6ea4'
        end
      when 'Linux'
        case version
        when '18.03.1' then '0e245c42de8a21799ab11179a4fce43b494ce173a8a2d6567ea6825d6c5265aa'
        when '18.06.3' then '346f9394393ee8db5f8bd1e229ee9d90e5b36931bdd754308b2ae68884dd6822'
        when '18.09.9' then '82a362af7689038c51573e0fd0554da8703f0d06f4dfe95dd5bda5acf0ae45fb'
        when '19.03.13' then 'ddb13aff1fcdcceb710bf71a210169b9c1abfd7420eeaf42cf7975f8fae2fcc8'
        end
      end
    end

    #########
    # Actions
    #########

    action :create do
      package 'tar'

      # Pull a precompiled binary off the network
      remote_file docker_tarball do
        source new_resource.source
        checksum new_resource.checksum
        owner 'root'
        group 'root'
        mode '0755'
        action :create
        notifies :run, 'execute[extract tarball]', :immediately
      end

      execute 'extract tarball' do
        action :nothing
        command "tar -xzf #{docker_tarball} --strip-components=1 -C #{docker_bin_prefix}"
      end

      group 'docker' do
        system true
      end
    end

    action :delete do
      file docker_bin do
        action :delete
      end

      group 'docker' do
        action :delete
      end
    end

    ################
    # Action Helpers
    ################
    declare_action_class.class_eval do
      def docker_bin_prefix
        '/usr/bin'
      end

      def docker_bin
        "#{docker_bin_prefix}/docker"
      end

      def docker_tarball
        "#{Chef::Config[:file_cache_path]}/docker-#{new_resource.version}.tgz"
      end
    end
  end
end
