require 'docker-swarm'

module DockerCookbook
  # Initialize a docker swarm
  class DockerSwarmWorker < DockerSwarmNodeBase
    require_relative 'helpers_swarm_cluster'

    include DockerHelpers::SwarmCluster

    # Resource properties
    resource_name :docker_swarm_worker

    declare_action_class.class_eval do
      def whyrun_supported?
        true
      end
    end

    # Resource actions
    action :create do
      ensure_swarm_available!
      return if cluster_initialized?

      if join_address.nil? || join_token.nil?
        raise 'Provide join_address & join_token'
      end
      converge_by 'Running swarm join' do
        cluster_join(:worker, join_address, join_token)
      end
    end
  end
end
