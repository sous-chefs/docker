require 'active_support/core_ext'

module DockerCookbook
  module DockerHelpers
    # Helpers for Docker Swarm Networks
    module SwarmService
      def reset_current_service
        @current_service = nil
      end

      def current_service
        @current_service ||= current_swarm.find_service_by_name(name)
      end

      def find_network_by_name(name)
        current_swarm.networks.each do |net|
          return net if net.name == name
        end
      end

      def network_name_to_id(name)
        net = find_network_by_name name
        return net.id if net
      end

      def current_service_changed?
        current_spec = current_service.hash['Spec']
        new_spec = current_spec.deep_dup.deep_merge(service_spec)

        # This helps debug idempotency
        Chef::Log.debug "Current spec for #{name}: #{current_spec.inspect}"
        Chef::Log.debug "Computed spec for #{name}: #{new_spec.inspect}"
        current_spec != new_spec
      end

      def current_force_update_counter
        current_spec = current_service.hash['Spec']
        current_spec['TaskTemplate']['ForceUpdate'] || 0
      end


      def create_service
        current_swarm.create_service(service_spec)
      end

      def update_service(force = false)
        spec = service_spec.deep_dup

        if force
            # For the update to be forced, you need to change the ForceUpdate
            # counter. We're wrapping to avoid overflow, although unlikely
          force_update = current_force_update_counter + 1 % 1000
          spec['TaskTemplate']['ForceUpdate'] = force_update
        end

        current_service.update(spec)
      end

      def service_spec
        spec = {
          'Name' => name,
          'TaskTemplate' => {
            'ContainerSpec' => service_container_spec,
            'LogDriver' => service_log_driver_spec,
            'Placement' => {},
            'Resources' => service_resources_spec,
            'RestartPolicy' => service_restart_spec,
          },
          'Mode' => service_replication_spec,
          'EndpointSpec' => { 'Ports' => service_endpoint_ports_spec },
          'UpdateConfig' => service_update_spec(:update),
          'RollbackConfig' => service_update_spec(:rollback),
          'Labels' => format_labels,
          'Networks' => service_network_spec,
        }

        spec
      end

      def format_labels
        labels.inject({}) do |memo, (key, value)|
          memo[key.to_s] = value
          memo
        end
      end

      def service_container_spec
        spec = {
          # 'Networks' => [],
          'Image' => image,
          'User' => user
        }

        spec['Mounts'] = mount_spec unless mounts.empty?
        spec['Env'] = format_env unless environment.empty?
        spec['Hostname'] = hostname unless hostname.empty?
        spec['HealthCheck'] = health_spec

        spec
      end

      def health_spec
        {
          # 'Test' => [],
          # 'Interval' => 0,
          # 'Timeout' => 0,
          # 'Retries' => 0,
          'StartPeriod' => health_start_period * 1_000_000_000
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
          'Condition' => restart_condition,
          'Delay' => restart_delay,
          'MaxAttempts' => restart_attempts,
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
            'PublishMode' => 'ingress',
          }
        end
      end

      def service_update_spec(kind)
        # This is rather stupid, but it is required for idempotency
        ratio = send("#{kind}_max_failure_ratio")
        ratio = ratio.to_i if ratio.to_i == ratio

        {
          'Delay' => send("#{kind}_delay") * 1_000_000_000,
          'Parallelism' => send("#{kind}_parallelism"),
          'Monitor' => send("#{kind}_monitor") * 1_000_000_000,
          'MaxFailureRatio' => ratio,
          'FailureAction' => send("#{kind}_failure_action"),
        }
      end

      def service_network_spec
        networks.map do |network_name|
          network_id = network_name_to_id network_name

          { 'Target' => network_id || network_name }
        end
      end

      def mount_spec
        mounts.map do |mount|
          spec = {
            'Target' => mount[:target],
            'Source' => mount[:source],
            'Type' => mount[:type].to_s,
            'ReadOnly' => mount[:readonly] || false
          }

          spec['Consistency'] = mount[:consistency] unless mount[:consistency].nil?

          %w[bind mount tmpfs].each do |mount_type|
            opt = mount["#{mount_type}_options"]
            if opt
              spec["#{mount_type.capitalize}Options"] =
                send("mount_#{mount_type}_options_spec", opt)
            end
          end

          spec
        end
      end

      def mount_bind_options_spec(opt)
        {
          'Propagation' => opt[:propagation]
        }
      end

      def mount_volume_options_spec(opt)
        {
          'NoCopy' => opt[:no_copy] || false,
          'Labels' => opt[:labels] || {},
          'DriverConfig' => mount_volume_options_driver_config_spec(
            opt[:driver_config]
          )
        }
      end

      def mount_volume_options_driver_config_spec(opt)
        return {} unless opt
        {
          'Name' => opt[:name],
          'Options' => opt[:options] || {}
        }
      end

      def mount_tmpfs_options_spec(opt)
        {
          'SizeBytes' => opt[:size_bytes],
          'Mode' => opt[:mode]
        }
      end
    end
  end
end
