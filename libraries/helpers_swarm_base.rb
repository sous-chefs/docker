require 'docker-swarm'

module DockerCookbook
  module DockerHelpers
    module SwarmBase
      def connection_klass
        Docker::Swarm::Connection
      end

      def default_host
        super || 'unix:///var/run/docker.sock'
      end

      def ensure_swarm_available!
        # XXX: Raise an error when Docker is not installed/running

        version = Docker.version['ApiVersion'].split('.')
        msg = 'Docker API Version >= 1.12 is required to use Docker Swarm'
        raise msg unless version[0].to_i >= 1 && version[1].to_i >= 12
      end

      def fetch_current_swarm_node
        current_swarm.nodes.each do |swarm_node|
          return swarm_node if swarm_node.id == current_swarm.id
        end
      end

      def current_swarm
        @current_swarm ||= Docker::Swarm::Swarm.find(connection)
      end

      def current_swarm_node
        @current_swarm_node ||= fetch_current_swarm_node
      end
    end
  end
end
