$LOAD_PATH.unshift *Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)]
require 'docker'
require 'shellwords'

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
        Docker::Container.get(new_resource.container_name)
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
        ::Shellwords.shellwords(new_resource.command)
      end

      # 22/tcp, 53/udp, etc
      def exposed_ports
        return nil if parsed_ports.empty?
        parsed_ports.inject({}) { |a, e| expand_port_exposure(a, e) }
      end

      def expand_port_exposure(exposings, value)
        exposings.merge(PortBinding.new(value).exposure)
      end

      # Map container exposed port to the host
      def port_bindings
        return nil if parsed_ports.empty?
        parsed_ports.inject({}) { |a, e| expand_port_binding(a, e) }
      end

      def expand_port_binding(binds, value)
        binds.merge(PortBinding.new(value).binding)
      end

      def parsed_ports
        return [] if new_resource.port.nil?
        return [] if new_resource.port.empty?
        Array(new_resource.port)
      end

      def parsed_binds
        Array(new_resource.binds)
      end

      def parsed_volumes_from
        Array(new_resource.volumes_from)
      end

      def parsed_volumes
        return nil if new_resource.volumes.nil?
        return nil if new_resource.volumes.empty?
        varray = Array(new_resource.volumes)
        vhash = {}
        varray.each { |v| vhash[v] = {} }
        vhash
      end

      def parsed_cap_add
        return nil if new_resource.cap_add.nil?
        return nil if new_resource.cap_add.empty?
        Array(new_resource.cap_add)
      end

      def parsed_cap_drop
        return nil if new_resource.cap_drop.nil?
        return nil if new_resource.cap_drop.empty?
        Array(new_resource.cap_drop)
      end

      def parsed_dns
        return nil if new_resource.dns.nil?
        return nil if new_resource.dns.empty?
        Array(new_resource.dns)
      end

      def parsed_dns_search
        return nil if new_resource.dns_search.nil?
        Array(new_resource.dns_search)
      end

      def parsed_extra_hosts
        return nil if new_resource.extra_hosts.nil?
        return nil if new_resource.extra_hosts.empty?
        Array(new_resource.extra_hosts)
      end

      def parsed_links
        return nil if new_resource.links.nil?
        return nil if new_resource.links.empty?
        Array(new_resource.links)
      end

      def parsed_env
        return nil if new_resource.env.nil?
        Array(new_resource.env)
      end

      def parsed_devices
        return nil if new_resource.devices.nil?
        Array(new_resource.devices)
      end

      def parsed_restart_policy
        {
          'MaximumRetryCount' => new_resource.restart_maximum_retry_count,
          'Name' => new_resource.restart_policy
        }
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
          'Env' => parsed_env,
          'ExposedPorts' => exposed_ports,
          'Hostname' => new_resource.host_name,
          'MacAddress' => new_resource.mac_address,
          'NetworkDisabled' => new_resource.network_disabled,
          'OpenStdin' => new_resource.open_stdin,
          'StdinOnce' => new_resource.stdin_once,
          'Tty' => new_resource.tty,
          'User' => new_resource.user,
          'Volumes' => parsed_volumes,
          'WorkingDir' => new_resource.working_dir,
          'HostConfig' => {
            'Binds' => parsed_binds,
            'CapAdd' => parsed_cap_add,
            'CapDrop' => parsed_cap_drop,
            'CgroupParent' => new_resource.cgroup_parent,
            'CpuShares' => new_resource.cpu_shares,
            'CpusetCpus' => new_resource.cpuset_cpus,
            'Devices' => parsed_devices,
            'Dns' => parsed_dns,
            'DnsSearch' => parsed_dns_search,
            'ExtraHosts' => parsed_extra_hosts,
            'Links' => parsed_links,
            'LogConfig' => new_resource.log_config,
            'Memory' => new_resource.memory,
            'MemorySwap' => new_resource.memory_swap,
            'NetworkMode' => new_resource.network_mode,
            'Privileged' => new_resource.privileged,
            'PortBindings' => port_bindings,
            'PublishAllPorts' => new_resource.publish_all_ports,
            'RestartPolicy' => parsed_restart_policy,
            'Ulimits' => new_resource.ulimits,
            'VolumesFrom' => parsed_volumes_from
          }
        )
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
        c = Docker::Container.get(new_resource.container_name)
        next if c.info['State']['Restarting']
        next if c.info['State']['Running']
        converge_by "starting #{new_resource.container_name}" do
          if new_resource.detach
            new_resource.attach_stdin false
            new_resource.attach_stdout false
            new_resource.attach_stderr false
            new_resource.stdin_once false
            c.start
          else
            c.start
            new_resource.timeout ? c.wait(new_resource.timeout) : c.wait
          end
        end
        new_resource.updated_by_last_action(true)
      end

      action :stop do
        next unless container_created?
        c = Docker::Container.get(new_resource.container_name)
        next unless c.info['State']['Running']
        converge_by "stopping #{new_resource.container_name}" do
          c.stop
        end
        new_resource.updated_by_last_action(true)
      end

      action :kill do
        next unless container_created?
        c = Docker::Container.get(new_resource.container_name)
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

      action :run_if_missing do
        next if container_created?
        action_run
      end

      action :pause do
        next unless container_created?
        c = Docker::Container.get(new_resource.container_name)
        next if c.info['State']['Paused']
        converge_by "pausing #{new_resource.container_name}" do
          c.pause
        end
        new_resource.updated_by_last_action(true)
      end

      action :unpause do
        next unless container_created?
        c = Docker::Container.get(new_resource.container_name)
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
        c = Docker::Container.get(new_resource.container_name)
        converge_by "deleting #{new_resource.container_name}" do
          c.delete(force: new_resource.force, v: new_resource.remove_volumes)
        end
        new_resource.updated_by_last_action(true)
      end

      action :remove do
        action_delete
      end

      action :remove_link do
        # Help! I couldn't get this working from the CLI in docker 1.6.2.
        # It's of dubious usefulness, and it looks like this stuff is
        # changing in 1.7.x anyway.
        converge_by "removing links for #{new_resource.container_name}" do
          Chef::Log.info(':remove_link not currently implemented')
        end
        new_resource.updated_by_last_action(true)
      end

      action :commit do
        c = Docker::Container.get(new_resource.container_name)
        converge_by "committing #{new_resource.container_name}" do
          new_image = c.commit
          new_image.tag('repo' => new_resource.repo, 'tag' => new_resource.tag, 'force' => new_resource.force)
        end
      end

      action :export do
        fail "Please set outfile property on #{new_resource.container_name}" if new_resource.outfile.nil?
        c = Docker::Container.get(new_resource.container_name)
        converge_by "exporting #{new_resource.container_name}" do
          ::File.open(new_resource.outfile, 'w') { |f| c.export { |chunk| f.write(chunk) } }
        end
      end
    end
  end
end
