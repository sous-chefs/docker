require 'docker-swarm'

module DockerCookbook
  require_relative 'docker_swarm_node_base'
  # Docker swarm manager init and join
  class DockerSwarmManager < DockerSwarmNodeBase
    require_relative 'helpers_swarm_cluster'

    include DockerHelpers::SwarmCluster

    # Resource properties
    resource_name :docker_swarm_manager

    property :first_manager, [TrueClass, FalseClass], default: false

    declare_action_class.class_eval do
      def whyrun_supported?
        true
      end
    end

    #########
    # Actions
    #########

    default_action :create

    action :create do
      ensure_swarm_available!
      return if cluster_initialized?

      if new_resource.first_manager
        converge_by 'Running swarm init' do
          manager_init
        end
      else
        if join_address.nil? || join_token.nil?
          raise 'Provide join_address & join_token or set `first_manager true`'
        end
        converge_by 'Running swarm join' do
          cluster_join(:manager, join_address, join_token)
        end
      end
    end
  end
end
