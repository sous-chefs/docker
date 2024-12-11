module DockerCookbook
  module DockerHelpers
    # Helpers for Docker Swarm Networks
    module SwarmNetwork
      def network_find(name)
        current_swarm.networks.select do |network|
          network.name == name
        end.first
      end

      def create_overlay_network(name)
        with_retries do
          current_swarm.create_network_overlay(name)
        end
      end

      def remove_overlay_network(network)
        with_retries do
          network.remove
        end
      end
    end
  end
end
