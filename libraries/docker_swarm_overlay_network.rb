require 'docker-swarm'

module DockerCookbook
  # Initialize a docker swarm
  class DockerSwarmOverlayNetwork < DockerSwarmBase
    require_relative 'helpers_swarm_network'

    include DockerHelpers::SwarmNetwork

    # Resource properties
    resource_name :docker_swarm_overlay_network
    property :network_name, String, name_propery: true

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
      return if network_find(new_resource.name)

      converge_by 'Create overlay network' do
        create_overlay_network(new_resource.name)
      end
    end

    action :destroy do
      ensure_swarm_available!

      network = network_find(new_resource.name)
      return unless network

      converge_by 'Destroying network' do
        remove_overlay_network(network)
      end
    end
  end
end
