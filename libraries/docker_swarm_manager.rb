require 'docker-swarm'

module DockerCookbook
  # Initialize a docker swarm
  class DockerSwarmManager < DockerSwarmBase
    require_relative 'helpers_swarm_manager'

    include DockerHelpers::SwarmManager

    # Resource properties
    resource_name :docker_swarm_manager

    property :cluster_name, String, name_propery: true
    property :listen_address, String, default: '0.0.0.0:2377'
    property :first_manager, Boolean, default: false

    property :worker_join_token, String
    property :manager_join_token, String

    declare_action_class.class_eval do
      def whyrun_supported?
        true
      end
    end

    # Resource actions
    action :create do
      ensure_swarm_available!
      return if cluster_initialized?

      if new_resource.first_manager
        converge_by 'Running swarm init' do
          manager_init
        end
      else
        converge_by 'Running swarm join' do
          manager_join
        end
      end
    end
  end
end
