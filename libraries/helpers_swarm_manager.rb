module DockerCookbook
  # Helpers for Docker Swarm Manager
  module DockerHelpers
    module SwarmManager
      def cluster_initialized?
        info = Docker.info
        # puts 'SWARM=', info['Swarm']
        info.key?('Swarm') && info['Swarm']['LocalNodeState'] == 'active'
      end

      def manager_init
        opts = { 'ListenAddr' => listen_address }

        swarm = nil
        with_retries do
          swarm = Docker::Swarm::Swarm.init(opts, connection)
        end

        node.normal['swarm'][name]['join_token']['manager'] =
          swarm.manager_join_token
        node.normal['swarm'][name]['join_token']['worker'] =
          swarm.manager_join_token
      end

      def manager_join
        puts 'Implement me !'
      end
    end
  end
end
