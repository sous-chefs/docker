module DockerCookbook
  class DockerInstallationPackage < DockerBase
    # helper_methods
    require 'helpers_installation_package'
    include DockerHelpers::InstallationPackage

    # Resource properties
    use_automatic_resource_name

    property :package_name, String, default: 'docker-engine', desired_state: false
    property :package_version, String, default: lazy { version_string(version) }, desired_state: false
    property :version, String, default: lazy { default_docker_version }, desired_state: false

    # Actions
    action :create do
      package package_name do
        version package_version
        action :install
      end
    end

    action :delete do
      package package_name do
        action :remove
      end
    end
  end
end
