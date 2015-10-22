module DockerCookbook
  class DockerInstallationBinary < DockerBase
    #####################
    # Resource properties
    #####################
    use_automatic_resource_name

    provides :docker_installation

    property :source, String, default: lazy { default_source }
    property :checksum, String, default: lazy { default_checksum }
    property :docker_bin, String, default: '/usr/bin/docker'

    default_action :create

    #########
    # Actions
    #########

    action :create do
      # Pull a precompiled binary off the network
      remote_file docker_bin do
        source new_resource.source
        checksum new_resource.checksum
        owner 'root'
        group 'root'
        mode '0755'
        action :create
      end
    end

    action :delete do
      file docker_bin do
        action :delete
      end
    end
  end
end
