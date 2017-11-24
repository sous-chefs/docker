module DockerCookbook
  module DockerHelpers
    # Helpers for Docker Swarm Networks
    module SwarmService
      def current_service
        @current_service ||= current_swarm.find_service_by_name(service_name)
      end

      def current_service_changed?
        current_spec = current_service.hash['Spec']
        new_spec = current_spec.deep_dup.deep_merge(service_spec)
        current_spec != new_spec
      end

      def create_service
        current_swarm.create_service(service_spec)
      end

      def update_service
        current_service.update(service_spec)
      end

      def service_spec
        {
          'Name' => name,
          'TaskTemplate' => {
            'ContainerSpec' => service_container_spec,
            'Env' => format_env,
            'LogDriver' => service_log_driver_spec,
            'Placement' => {},
            'Resources' => service_resources_spec,
            'RestartPolicy' => service_restart_spec,
          },
          'Mode' => service_replication_spec,
          'EndpointSpec' => { 'Ports' => service_endpoint_ports_spec },
          'UpdateConfig' => service_update_spec(:update),
          'RollbackConfig' => service_update_spec(:rollback),
          'Labels' => labels,
          'Networks' => networks,
        }
      end

      def service_container_spec
        {
          'Networks' => [],
          'Image' => image,
          'User' => user,
          'Mounts' => '',
        }
      end

      def format_env
        environment.map { |k, v| [k, v].join('=') }
      end

      def service_log_driver_spec
        hash = { 'Name' => log_driver }
        hash['Options'] = log_driver_opts if log_driver_opts
        hash
      end

      def service_resources_spec
        {
          'Limits' => limits,
          'Reservations' => reservations,
        }
      end

      def service_restart_spec
        {
          'Condition' => 'on-failure',
          'Delay' => 1,
          'MaxAttempts' => 3,
        }
      end

      def service_replication_spec
        if global
          # XXX: This is a wild guess as I haven't been able to find doc on this
          { 'Global' => {} }
        else
          { 'Replicated' => { 'Replicas' => replicas } }
        end
      end

      def service_endpoint_ports_spec
        ports.map do |hash|
          {
            'Protocol' => hash[:proto] || 'tcp',
            'PublishedPort' => hash[:published],
            'TargetPort' => hash[:target],
          }
        end
      end

      def service_update_spec(kind)
        {
          'Delay' => send("#{kind}_delay"),
          'Parallelism' => send("#{kind}_parallelism"),
          'Monitor' => send("#{kind}_monitor"),
          'MaxFailureRatio' => send("#{kind}_max_failure_ratio"),
          'FailureAction' => send("#{kind}_failure_action"),
        }
      end
    end
  end
end
