module DockerCookbook
  class DockerInstallationScript < DockerBase
    #####################
    # Resource properties
    #####################
    use_automatic_resource_name

    property :repo, %w(main testing experimental), default: 'main'
    property :script_url, String, default: lazy { default_script_url }

    default_action :create

    ################
    # helper methods
    ################

    def default_script_url
      case repo
      when 'main'
        'https://get.docker.com/'
      when 'testing'
        'https://testing.docker.com/'
      when 'experimental'
        'https://testing.docker.com/'
      end
    end

    #########
    # Actions
    #########

    action :create do
      package 'curl' do
        action :install
      end

      execute 'install docker' do
        command "curl -sSL #{script_url} | sh"
        creates '/usr/bin/docker'
      end
    end

    action :delete do
      package 'docker-engine' do
        action :remove
      end
    end
  end
end
