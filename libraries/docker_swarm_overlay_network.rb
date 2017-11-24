require 'docker-swarm'

module DockerCookbook
  # Initialize a docker swarm
  class DockerSwarmOverlayNetwork < DockerSwarmBase
    require_relative 'helpers_swarm_network'

    include DockerHelpers::SwarmNetwork

    property :network_name, String, name_propery: true

    declare_action_class.class_eval do
      def whyrun_supported?
        true
      end
    end

    action :create do
      ensure_swarm_available!
      return if network_find(name)

      converge_by 'Create overlay network' do
        create_overlay_network(name)
      end
    end

    action :destroy do
      ensure_swarm_available!

      network = network_find(name)
      return unless network

      converge_by 'Destroying network' do
        remove_overlay_network(network)
      end
    end
  end
end
