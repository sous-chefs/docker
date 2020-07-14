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
    property :networks, [Array, nil], required: true,
             coerce: proc { |v| Array(v).empty? ? nil : Array(v) }
    property :hostname, String

    property :environment, Hash, default: {}
    property :log_driver, String, required: true, default: 'json-file'
    property :log_driver_opts, Hash,
             default: { 'max-file' => '3', 'max-size' => '10M' }

    property :limits, Hash, default: {}
    property :reservations, Hash, default: {}

    property :restart_condition, String, required: true, default: 'on-failure'
    property :restart_delay, Integer, required: true, default: 1
    property :restart_attempts, Integer, required: true, default: 3

    property :health_start_period, Integer, required: true, default: 10

    property :global, [TrueClass, FalseClass], required: true, default: false
    property :replicas, Integer, default: 1
    property :ports, Array, default: []
    property :labels, Hash, default: {}
    property :mounts, Array, default: []

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

    action :update do
      ensure_swarm_available!

      # To avoid using a stale version of the current service spec when
      # executing two actions against the same resource in the same run (and
      # have an out of sequence ForceUpdate counter). We reset our cached
      # service spec before every update
      reset_current_service

      if current_service_changed?
        converge_by('Update service') { update_service }
      end
    end

    action :force_update do
      ensure_swarm_available!

      # See #update comment
      reset_current_service

      converge_by('Update service [forced]') do
        update_service(true)
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
