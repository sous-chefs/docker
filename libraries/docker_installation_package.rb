module DockerCookbook
  class DockerInstallationPackage < DockerBase
    # helper_methods
    require 'helpers_installation_package'
    include DockerHelpers::InstallationPackage

    # Resource properties
    use_automatic_resource_name

    property :package_version, String, default: lazy { version_string(version) }
    property :version, String, default: lazy { default_docker_version }

    # Actions
    action :create do
      package 'docker-engine' do
        version package_version
        action :install
      end
    end

    action :delete do
      package 'docker-engine' do
        action :remove
      end
    end
  end
end
