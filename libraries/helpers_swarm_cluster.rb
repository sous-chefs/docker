module DockerCookbook
  # Helpers for Docker Swarm Manager
  module DockerHelpers
    module SwarmCluster
      def cluster_initialized?
        info = Docker.info
        # puts 'SWARM=', info['Swarm']
        info.key?('Swarm') && info['Swarm']['LocalNodeState'] == 'active'
      end

      def manager_init
        opts = { 'ListenAddr' => "#{listen_address}:2377" }

        with_retries do
          swarm = Docker::Swarm::Swarm.init(opts, connection)

          node.normal['swarm'][name]['first_manager'] = true
          node.normal['swarm'][name]['join']['address'] = listen_address
          node.normal['swarm'][name]['join']['manager_token'] =
            swarm.manager_join_token
          node.normal['swarm'][name]['join']['worker_token'] =
            swarm.manager_join_token

          swarm
        end
      end

      # def cluster_join_info(cluster_name)
      #   managers = search(:node, "swarm:#{cluster_name}").select do |n|
      #     n['swarm'][cluster_name].key?('join') &&
      #       n['swarm'][cluster_name]['join'].key?('manager_token')
      #   end

      #   managers.first['swarm'][cluster_name]['join'] if manager.first
      # end

      def cluster_join(type, join_address, join_token)
        opts = {
          'manager_ip' => join_address,
          'node_ip' => listen_address,
        }

        with_retries do
          swarm = Docker::Swarm::Swarm.new(swarm_options)
          if type == :manager
            opts['JoinTokens'] = { 'Master' => join_token }
            swarm.join_manager(connection)
          else
            opts['JoinTokens'] = { 'Worker' => join_token }
            swarm.join_worker(connection)
          end

          swarm
        end
      end

      def cluster_leave(force)
        with_retries do
          Docker::Swarm::Swarm.leave(force, connection)
        end
      end
    end
  end
end
