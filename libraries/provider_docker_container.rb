$LOAD_PATH.unshift *Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)]
require 'docker'
require 'shellwords'
require_relative 'helpers_container'

class Chef
  class Provider
    class DockerContainer < Chef::Provider::LWRPBase
      # register with the resource resolution system
      provides :docker_container if Chef::Provider.respond_to?(:provides)

      include DockerHelpers::Container
      use_inline_resources

      def load_current_resource
        @api_version = Docker.version['ApiVersion']

        @current_resource = Chef::Resource::DockerContainer.new(new_resource.name)
        begin
          c = Docker::Container.get(new_resource.container_name)
          @current_resource.attach_stderr c.info['Config']['AttachStderr']
          @current_resource.attach_stdin c.info['Config']['AttachStdin']
          @current_resource.attach_stdout c.info['Config']['AttachStdout']
          @current_resource.binds c.info['HostConfig']['Binds']
          @current_resource.cap_add c.info['HostConfig']['CapAdd']
          @current_resource.cap_drop c.info['HostConfig']['CapDrop']
          @current_resource.cgroup_parent c.info['HostConfig']['CgroupParent']
          @current_resource.command c.info['Config']['Cmd']
          @current_resource.cpu_shares c.info['HostConfig']['CpuShares']
          @current_resource.cpuset_cpus c.info['HostConfig']['CpusetCpus']
          @current_resource.devices c.info['HostConfig']['Devices']
          @current_resource.dns c.info['HostConfig']['Dns']
          @current_resource.dns_search c.info['HostConfig']['DnsSearch']
          @current_resource.domainname c.info['Config']['Domainname']
          @current_resource.entrypoint c.info['Config']['Entrypoint']
          @current_resource.env c.info['Config']['Env']
          @current_resource.exposed_ports c.info['Config']['ExposedPorts']
          @current_resource.extra_hosts c.info['HostConfig']['ExtraHosts']
          @current_resource.hostname c.info['Config']['Hostname']
          @current_resource.image c.info['Config']['Image']
          @current_resource.links c.info['HostConfig']['Links']
          @current_resource.log_config c.info['HostConfig']['LogConfig']
          @current_resource.mac_address c.info['Config']['MacAddress']
          @current_resource.memory c.info['HostConfig']['Memory']
          @current_resource.memory_swap c.info['HostConfig']['MemorySwap']
          @current_resource.network_disabled c.info['Config']['NetworkDisabled']
          @current_resource.network_mode c.info['HostConfig']['NetworkMode']
          @current_resource.open_stdin c.info['Config']['OpenStdin']
          @current_resource.port_bindings c.info['HostConfig']['PortBindings']
          @current_resource.privileged c.info['HostConfig']['Privileged']
          @current_resource.publish_all_ports c.info['HostConfig']['PublishAllPorts']
          @current_resource.restart_policy c.info['HostConfig']['RestartPolicy']
          @current_resource.stdin_once c.info['Config']['StdinOnce']
          @current_resource.tty c.info['Config']['Tty']
          @current_resource.ulimits c.info['HostConfig']['Ulimits']
          @current_resource.user c.info['Config']['User']
          @current_resource.volumes c.info['Config']['Volumes']
          @current_resource.volumes_from c.info['HostConfig']['VolumesFrom']
          @current_resource.working_dir c.info['Config']['WorkingDir']
        rescue Docker::Error::NotFoundError
          return @current_resource
        end
      end

      def resource_changes
        changes = []
        changes << :attach_stderr if current_resource.attach_stderr != parsed_attach_stderr
        changes << :attach_stdin if current_resource.attach_stdin != parsed_attach_stdin
        changes << :attach_stdout if current_resource.attach_stdout != parsed_attach_stdout
        changes << :binds if current_resource.binds != parsed_binds
        changes << :cap_add if current_resource.cap_add != parsed_cap_add
        changes << :cap_drop if current_resource.cap_drop != parsed_cap_drop
        changes << :cgroup_parent if current_resource.cgroup_parent != new_resource.cgroup_parent
        changes << :command if update_command?
        changes << :cpu_shares if current_resource.cpu_shares != new_resource.cpu_shares
        changes << :cpuset_cpus if current_resource.cpuset_cpus != new_resource.cpuset_cpus
        changes << :devices if current_resource.devices != parsed_devices
        changes << :dns if current_resource.dns != parsed_dns
        changes << :dns_search if current_resource.dns_search != parsed_dns_search
        changes << :domainname if current_resource.domainname != new_resource.domainname
        changes << :entrypoint if update_entrypoint?
        changes << :env if update_env?
        changes << :exposed_ports if update_exposed_ports?
        changes << :extra_hosts if current_resource.extra_hosts != parsed_extra_hosts
        changes << :hostname if update_hostname?
        changes << :image if current_resource.image != "#{parsed_repo}:#{new_resource.tag}"
        changes << :links if current_resource.links != serialized_links
        changes << :log_config if current_resource.log_config != serialized_log_config
        changes << :mac_address if current_resource.mac_address != new_resource.mac_address
        changes << :memory if current_resource.memory != new_resource.memory
        changes << :memory_swap if current_resource.memory_swap != new_resource.memory_swap
        changes << :network_disabled if current_resource.network_disabled != new_resource.network_disabled
        changes << :network_mode if current_resource.network_mode != parsed_network_mode
        changes << :open_stdin if current_resource.open_stdin != new_resource.open_stdin
        changes << :port_bindings if current_resource.port_bindings != port_bindings
        changes << :privileged if current_resource.privileged != new_resource.privileged
        changes << :publish_all_ports if current_resource.publish_all_ports != new_resource.publish_all_ports
        changes << :restart_policy if current_resource.restart_policy != parsed_restart_policy
        changes << :stdin_once if current_resource.stdin_once != parsed_stdin_once
        changes << :tty if current_resource.tty != new_resource.tty
        changes << :ulimits if update_ulimits?
        changes << :user if current_resource.user != new_resource.user
        changes << :volumes if update_volumes?
        changes << :volumes_from if current_resource.volumes_from != parsed_volumes_from
        changes << :working_dir if update_working_dir?
        changes
      end

      # Most important work is done here.
      def create_container
        api_timeouts
        tries ||= new_resource.api_retries
        Docker::Container.create(
          'name' => new_resource.container_name,
          'Image' => "#{parsed_repo}:#{new_resource.tag}",
          'Cmd' => parsed_command,
          'AttachStderr' => parsed_attach_stderr,
          'AttachStdin' => parsed_attach_stdin,
          'AttachStdout' => parsed_attach_stdout,
          'Domainname' => new_resource.domain_name,
          'Entrypoint' => parsed_entrypoint,
          'Env' => parsed_env,
          'ExposedPorts' => exposed_ports,
          'Hostname' => new_resource.host_name,
          'MacAddress' => new_resource.mac_address,
          'NetworkDisabled' => new_resource.network_disabled,
          'OpenStdin' => new_resource.open_stdin,
          'StdinOnce' => parsed_stdin_once,
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
            'LogConfig' => serialized_log_config,
            'Memory' => new_resource.memory,
            'MemorySwap' => new_resource.memory_swap,
            'NetworkMode' => parsed_network_mode,
            'Privileged' => new_resource.privileged,
            'PortBindings' => port_bindings,
            'PublishAllPorts' => new_resource.publish_all_ports,
            'RestartPolicy' => parsed_restart_policy,
            'Ulimits' => serialized_ulimits,
            'VolumesFrom' => parsed_volumes_from
          }
        )
      rescue Docker::Error => e
        retry unless (tries -= 1).zero?
        raise e.message
      end

      #########
      # Actions
      #########

      # Super handy visual reference!
      # http://gliderlabs.com/images/docker_events.png

      action :create do
        # Debug logging for things that have given trouble in the past
        Chef::Log.debug("DOCKER: user - current:#{current_resource.user}: new:#{new_resource.user}:")
        Chef::Log.debug("DOCKER: working_dir - current:#{current_resource.working_dir}: new:#{new_resource.working_dir}:")
        Chef::Log.debug("DOCKER: command - current:#{current_resource.command}: parsed:#{parsed_command}:")
        Chef::Log.debug("DOCKER: entrypoint - current:#{current_resource.entrypoint}: parsed:#{parsed_entrypoint}:")
        Chef::Log.debug("DOCKER: env - current:#{current_resource.env}: parsed:#{parsed_env}:")
        Chef::Log.debug("DOCKER: exposed_ports - current:#{current_resource.exposed_ports}: serialized:#{exposed_ports}:")
        Chef::Log.debug("DOCKER: volumes - current:#{current_resource.volumes}: parsed:#{parsed_volumes}:")
        Chef::Log.debug("DOCKER: network_mode - current:#{current_resource.network_mode}: parsed:#{parsed_network_mode}:")
        Chef::Log.debug("DOCKER: log_config - current:#{current_resource.log_config}: serialized:#{serialized_log_config}:")
        Chef::Log.debug("DOCKER: ulimits - current:#{current_resource.ulimits}:")
        Chef::Log.debug("DOCKER: ulimits -     new:#{new_resource.ulimits}:")
        Chef::Log.debug("DOCKER: links - current:#{current_resource.links}: serialized:#{serialized_links}:")

        resource_changes.each do |change|
          Chef::Log.debug("DOCKER: change - :#{change}")
        end

        action_delete unless resource_changes.empty? || !container_created?

        next if container_created?
        converge_by "creating #{new_resource.container_name}" do
          create_container
        end
        new_resource.updated_by_last_action(true)
      end

      action :start do
        api_timeouts
        c = Docker::Container.get(new_resource.container_name)
        next if c.info['State']['Restarting']
        next if c.info['State']['Running']
        converge_by "starting #{new_resource.container_name}" do
          begin
            tries ||= new_resource.api_retries

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

          rescue Docker::Error => e
            retry unless (tries -= 1).zero?
            raise e.message
          end
        end
        new_resource.updated_by_last_action(true)
      end

      action :stop do
        api_timeouts
        next unless container_created?
        c = Docker::Container.get(new_resource.container_name)
        next unless c.info['State']['Running']
        converge_by "stopping #{new_resource.container_name}" do
          begin
            tries ||= new_resource.api_retries
            c.stop
          rescue Docker::Error => e
            retry unless (tries -= 1).zero?
            raise e.message
          end
        end
        new_resource.updated_by_last_action(true)
      end

      action :kill do
        api_timeouts
        next unless container_created?
        c = Docker::Container.get(new_resource.container_name)
        next unless c.info['State']['Running']
        converge_by "killing #{new_resource.container_name}" do
          begin
            tries ||= new_resource.api_retries
            c.kill(signal: new_resource.signal)
          rescue Docker::Error => e
            retry unless (tries -= 1).zero?
            raise e.message
          end
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
        api_timeouts
        next unless container_created?
        c = Docker::Container.get(new_resource.container_name)
        next if c.info['State']['Paused']
        converge_by "pausing #{new_resource.container_name}" do
          begin
            tries ||= new_resource.api_retries
            c.pause
          rescue Docker::Error => e
            retry unless (tries -= 1).zero?
            raise e.message
          end
        end
        new_resource.updated_by_last_action(true)
      end

      action :unpause do
        api_timeouts
        next unless container_created?
        c = Docker::Container.get(new_resource.container_name)
        next unless c.info['State']['Paused']
        converge_by "unpausing #{new_resource.container_name}" do
          begin
            tries ||= new_resource.api_retries
            c.unpause
          rescue Docker::Error => e
            retry unless (tries -= 1).zero?
            raise e.message
          end
        end
        new_resource.updated_by_last_action(true)
      end

      action :restart do
        action_stop
        action_start
      end

      action :redeploy do
        c = Docker::Container.get(new_resource.container_name)
        action_delete
        # never start containers resulting from a previous action :create #432
        if c.info['State']['Running'] == false &&
           c.info['State']['StartedAt'] == '0001-01-01T00:00:00Z'
          action_create
        else
          action_run
        end
      end

      action :delete do
        next unless container_created?
        action_unpause
        action_stop
        c = Docker::Container.get(new_resource.container_name)
        converge_by "deleting #{new_resource.container_name}" do
          begin
            tries ||= new_resource.api_retries
            c.delete(force: new_resource.force, v: new_resource.remove_volumes)
          rescue Docker::Error => e
            retry unless (tries -= 1).zero?
            raise e.message
          end
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
        api_timeouts
        c = Docker::Container.get(new_resource.container_name)
        converge_by "committing #{new_resource.container_name}" do
          begin
            tries ||= new_resource.api_retries
            new_image = c.commit
            new_image.tag('repo' => new_resource.repo, 'tag' => new_resource.tag, 'force' => new_resource.force)
          rescue Docker::Error => e
            retry unless (tries -= 1).zero?
            raise e.message
          end
        end
      end

      action :export do
        api_timeouts
        fail "Please set outfile property on #{new_resource.container_name}" if new_resource.outfile.nil?
        c = Docker::Container.get(new_resource.container_name)
        converge_by "exporting #{new_resource.container_name}" do
          begin
            tries ||= new_resource.api_retries
            ::File.open(new_resource.outfile, 'w') { |f| c.export { |chunk| f.write(chunk) } }
          rescue Docker::Error => e
            retry unless (tries -= 1).zero?
            raise e.message
          end
        end
      end
    end
  end
end
