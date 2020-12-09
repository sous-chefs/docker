require 'docker-swarm'

module DockerCookbook
  # Initialize a docker swarm
  class DockerSwarmNodeBase < DockerSwarmBase
    require_relative 'helpers_swarm_cluster'

    include DockerHelpers::SwarmCluster

    property :cluster_name, String, name_propery: true
    property :listen_address, String, default: '0.0.0.0'

    property :join_address, String
    property :join_token, String
    property :force_leave, [TrueClass, FalseClass], default: true

    property :drain_opts, Hash, default: {}

    declare_action_class.class_eval do
      def whyrun_supported?
        true
      end
    end

    action :drain do
      ensure_swarm_available!
      return unless cluster_initialized?
      return if current_swarm_node.running_tasks == 0

      converge_by 'Draining node' do
        current_swarm_node.drain(drain_opts)
      end
    end

    action :destroy do
      ensure_swarm_available!
      return unless cluster_initialized?

      converge_by "Leaving the cluster (force=#{force_leave})" do
        cluster_leave(force_leave)
      end
    end
  end
end
