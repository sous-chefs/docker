require 'docker-swarm'

module DockerCookbook
  # Initialize a docker swarm
  class DockerSwarmService < DockerSwarmBase
    require_relative 'helpers_swarm_service'

    include DockerHelpers::SwarmService

    resource_name :docker_swarm_service

    property :service_name, String, name_propery: true

    property :image, String, required: true
    property :user, String, required: true, default: 'root'
    property :networks, NonEmptyArray, required: true

    property :environment, Hash, default: {}
    property :log_driver, String, required: true, default: 'json-file'
    property :log_driver_opts, Hash,
             default: { 'max-file' => '3', 'max-size' => '10M' }

    property :limits, Hash, default: {}
    property :reservations, Hash, default: {}

    property :restart_condition, String, required: true, default: 'on-failure'
    property :restart_delay, Integer, required: true, default: 1
    property :restart_attemps, Integer, required: true, default: 3

    property :global, Boolean, required: true, default: false
    property :replicas, Integer, default: 1
    property :ports, Array, default: []
    property :labels, Hash, default: {}

    %i(update rollback).each do |kind|
      property "#{kind}_parallelism".to_sym, Integer, required: true, default: 1
      property "#{kind}_delay".to_sym, Integer, required: true, default: 1
      property "#{kind}_monitor".to_sym, Integer, required: true, default: 15
      property "#{kind}_max_failure_ratio".to_sym, Float,
               required: true,
               default: 0.0
      property "#{kind}_failure_action".to_sym, %w(pause continue rollback),
               required: true,
               default: 'pause'
    end

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

      if current_service.nil?
        converge_by('Create service') { create_service }
      elsif current_service_changed?
        converge_by('Update service') { update_service }
      end
    end

    action :destroy do
      ensure_swarm_available!
      return unless current_service

      converge_by 'Delete service' do
        current_service.remove
      end
    end
  end
end
