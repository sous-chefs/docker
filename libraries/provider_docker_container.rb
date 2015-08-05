$LOAD_PATH.unshift *Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)]
require 'docker'

class Chef
  class Provider
    class DockerContainer < Chef::Provider::LWRPBase
      # register with the resource resolution system
      provides :docker_container if Chef::Provider.respond_to?(:provides)

      ################
      # Helper methods
      ################

      # This is called a lot.. maybe this should turn into an instance variable
      def container_created?
        Docker::Container.get("#{new_resource.container_name}")
        return true
      rescue Docker::Error::NotFoundError
        return false
      end

      # Use this instead of new_resource.repo
      def parsed_repo
        return new_resource.repo if new_resource.repo
        new_resource.container_name
      end

      # The remote API wants an argv style array
      def parsed_command
        new_resource.command.gsub(/\s+/m, ' ').gsub(/^\s+|\s+$/m, '').split(' ')
      end

      # ip:hostPort:containerPort | ip::containerPort | hostPort:containerPort | containerPort
      def host_ip
        parts = new_resource.port.split(':')
        return parts[0] if parts.size == 3
        '0.0.0.0'
      end

      def host_port
        parts = new_resource.port.split(':')
        return parts[1] if parts.size == 3
        return parts[0] if parts.size == 2
        nil
      end

      def container_port
        parts = new_resource.port.split(':')
        return parts[2] if parts.size == 3
        return parts[1] if parts.size == 2
        return parts[0] if parts.size == 1
      end

      # 22/tcp, 53/udp, etc
      def exposed_ports
        { "#{container_port}" => {} }
      end

      # Map container exposed port to the host
      def port_bindings
        return nil if new_resource.port.nil?
        return nil if new_resource.port.empty?
        {
          "#{container_port}" => [
            {
              'HostIp' => "#{host_ip}",
              'HostPort' => "#{host_port}"
            }
          ]
        }
      end

      def parsed_binds
        # require 'pry' ; binding.pry if new_resource.container_name == 'bind_mounter'
        Array(new_resource.binds)
      end

      def parsed_volumes_from
        Array(new_resource.volumes_from)
      end

      # Most important work is done here.
      def create_container
        Docker::Container.create(
          'name' => new_resource.container_name,
          'Image' => "#{parsed_repo}:#{new_resource.tag}",
          'Cmd' => parsed_command,
          'AttachStderr' => new_resource.attach_stderr,
          'AttachStdin' => new_resource.attach_stdin,
          'AttachStdout' => new_resource.attach_stdout,
          'Domainname' => new_resource.domain_name,
          'Entrypoint' => new_resource.entrypoint,
          'Env' => new_resource.env,
          'ExposedPorts' => exposed_ports,
          'Hostname' => new_resource.host_name,
          'MacAddress' => new_resource.mac_address,
          'NetworkDisabled' => new_resource.network_disabled,
          'NetworkMode' => new_resource.network_mode,
          'OpenStdin' => new_resource.open_stdin,
          'StdinOnce' => new_resource.stdin_once,
          'Tty' => new_resource.tty,
          'User' => new_resource.user,
          'WorkingDir' => new_resource.working_dir,
          'HostConfig' => {
            'Binds' => parsed_binds,
            'CapAdd' => new_resource.cap_add,
            'CapDrop' => new_resource.cap_drop,
            'CgroupParent' => new_resource.cgroup_parent,
            'CpuShares' => new_resource.cpu_shares,
            'CpusetCpus' => new_resource.cpuset_cpus,
            'Devices' => new_resource.devices,
            'Dns' => new_resource.dns,
            'DnsSearch' => new_resource.dns_search,
            'ExtraHosts' => new_resource.extra_hosts,
            'Links' => new_resource.links,
            'LogConfig' => new_resource.log_config,
            'Memory' => new_resource.memory,
            'MemorySwap' => new_resource.memory_swap,
            'Privileged' => new_resource.privileged,
            'PortBindings' => port_bindings,
            'PublishAllPorts' => new_resource.publish_all_ports,
            'RestartPolicy' => new_resource.restart_policy,
            'Ulimits' => new_resource.ulimits,
            'Volumes' => new_resource.volumes,
            'VolumesFrom' => parsed_volumes_from
          }
        )
        rescue Docker::Error => e
          raise e.message
      end

      # Super handy visual reference!
      # http://gliderlabs.com/images/docker_events.png

      #########
      # Actions
      #########

      action :create do
        next if container_created?
        converge_by "creating #{new_resource.container_name}" do
          create_container
        end
        new_resource.updated_by_last_action(true)
      end

      action :start do
        c = Docker::Container.get("#{new_resource.container_name}")
        next if c.info['State']['Restarting']
        next if c.info['State']['Running']
        converge_by "starting #{new_resource.container_name}" do
          c.start
        end
        new_resource.updated_by_last_action(true)
      end

      action :stop do
        next unless container_created?
        c = Docker::Container.get("#{new_resource.container_name}")
        next unless c.info['State']['Running']
        converge_by "stopping #{new_resource.container_name}" do
          c.stop
        end
        new_resource.updated_by_last_action(true)
      end

      action :kill do
        next unless container_created?
        c = Docker::Container.get("#{new_resource.container_name}")
        next unless c.info['State']['Running']
        converge_by "killing #{new_resource.container_name}" do
          c.kill(signal: new_resource.signal)
        end
        new_resource.updated_by_last_action(true)
      end

      action :run do
        action_create
        action_start
        action_delete if new_resource.autoremove
      end

      action :pause do
        next unless container_created?
        c = Docker::Container.get("#{new_resource.container_name}")
        next if c.info['State']['Paused']
        converge_by "pausing #{new_resource.container_name}" do
          c.pause
        end
        new_resource.updated_by_last_action(true)
      end

      action :unpause do
        next unless container_created?
        c = Docker::Container.get("#{new_resource.container_name}")
        next unless c.info['State']['Paused']
        converge_by "unpausing #{new_resource.container_name}" do
          c.unpause
        end
        new_resource.updated_by_last_action(true)
      end

      action :restart do
        action_stop
        action_start
      end

      action :redeploy do
        action_delete
        action_run
      end

      action :delete do
        next unless container_created?
        action_unpause
        action_stop
        c = Docker::Container.get("#{new_resource.container_name}")
        converge_by "deleting #{new_resource.container_name}" do
          c.delete(force: true)
        end
        new_resource.updated_by_last_action(true)
      end
    end
  end
end
