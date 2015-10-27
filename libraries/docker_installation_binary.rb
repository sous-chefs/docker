module DockerCookbook
  class DockerInstallationBinary < DockerBase
    require 'helpers_installation_binary'
    include DockerHelpers::InstallationBinary

    #####################
    # Resource properties
    #####################
    use_automatic_resource_name

    property :checksum, String, default: lazy { default_checksum }
    property :source, String, default: lazy { default_source }
    property :version, String, default: lazy { default_version }

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
