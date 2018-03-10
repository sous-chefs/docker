module DockerCookbook
  class DockerInstallationTarball < DockerBase
    resource_name :docker_installation_tarball

    property :checksum, String, default: lazy { default_checksum }, desired_state: false
    property :source, String, default: lazy { default_source }, desired_state: false
    property :channel, String, default: 'stable', desired_state: false
    property :version, String, default: '17.12.0', desired_state: false

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
      "https://download.docker.com/#{docker_kernel.downcase}/static/#{channel}/#{docker_arch}/docker-#{version}-ce.tgz"
    end

    def default_checksum
      case docker_kernel
      when 'Darwin'
        case version
        when '17.12.0' then 'dc673421e0368c2c970203350a9d0cb739bc498c897e832779369b0b2a9c6192'
        end
      when 'Linux'
        case version
        when '17.12.0' then '692e1c72937f6214b1038def84463018d8e320c8eaf8530546c84c2f8f9c767d'
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
        creates docker_bin
      end
    end

    action :delete do
      file docker_bin do
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
