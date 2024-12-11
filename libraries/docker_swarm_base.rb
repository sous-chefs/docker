module DockerCookbook
  # We override the DockerBase to use the Docker Swarm SDK Connection object
  class DockerSwarmBase < DockerBase
    require_relative 'helpers_base'
    include DockerHelpers::Base
    require_relative 'helpers_swarm_base'
    include DockerHelpers::SwarmBase

    property :host, [String, nil], default: lazy { default_host }, desired_state: false

    def swarm_info
    end
  end
end
