require 'docker'
require 'shellwords'
require 'helpers_container'

class Chef
  class Resource
    class DockerContainer < DockerBase
      use_automatic_resource_name

      property :container_name,    String,       name_property: true
      property :repo,              String,       default: lazy { container_name }
      property :tag,               String,       default: 'latest'
      property :command,           ShellCommand

      property :api_retries,       Fixnum,       default: 3
      property :attach_stderr,     Boolean,      default: lazy { detach }
      property :attach_stdin,      Boolean,      default: false
      property :attach_stdout,     Boolean,      default: lazy { detach }
      property :autoremove,        Boolean
      property :binds,             ArrayType
      property :cap_add,           NonEmptyArray
      property :cap_drop,          NonEmptyArray
      property :cgroup_parent,     String,        default: '' # FIXME: add validate proc
      property :cpu_shares,        [Fixnum, nil], default: 0 # FIXME: add validate proc
      property :cpuset_cpus,       String,        default: '' # FIXME: add validate proc
      property :detach,            Boolean,       default: true
      property :devices,           ArrayType
      property :dns,               NonEmptyArray
      property :dns_search,        NullableArray
      property :domain_name,       String,        default: ''
      property :entrypoint,        ShellCommand
      property :env,               ArrayType
      property :extra_hosts,       NonEmptyArray
      property :exposed_ports,     [Hash, nil]
      property :force,             Boolean
      property :host,              [String, nil]
      property :host_name,         [String, nil]
      property :labels,            Hash,          coerce: (proc do |v|
        if v.is_a?(Hash)
          v
        else
          Array(v).each_with_object({}) do |label,h|
            parts = label.split(':')
            h[parts[0]] = parts[1]
          end
        end
      end)
      property :links,             [Array, nil],  coerce: (proc do |v|
        v = Array(v)
        return nil if v.empty?
        # Parse docker input of /source:/container_name/dest into source:dest
        v.map do |link|
          if link =~ /^\/(.+):\/#{name}\/(.+)/
            link = "#{$1}:#{$2}"
          end
          link
        end
      end)
      property :log_config,        Hash,          coerce: (proc do |v|
        v ||= {}
        v['Type'] ||= log_driver
        v['Config'] ||= log_opts
        v
      end)
      property :log_driver, %w( json-file syslog journald gelf fluentd none ), default: 'json-file'
      property :log_opts,          [Hash, nil],          coerce: (proc do |v|
        case v
        when Hash, nil
          v
        else
          Array(v).each_with_object({}) do |log_opt, memo|
            key, value = log_opt.split('=', 2)
            memo[key] = value
          end
        end
      end)
      property :mac_address,       String,         default: '' # FIXME: needs tests
      property :memory,            Fixnum,         default: 0
      property :memory_swap,       Fixnum,         default: -1
      property :network_disabled,  Boolean,        default: false
      property :network_mode,      [String, nil],  default: (lazy do
        case api_version
        when '1.20'
          'default'
        when '1.19'
          'bridge'
        else
          ''
        end
      end)
      property :open_stdin,        Boolean,         default: false
      property :outfile,           String,          default: nil
      property :port,              ArrayType,       default: nil
      property :port_bindings,     [String, Array, Hash, nil]
      property :privileged,        Boolean
      property :publish_all_ports, Boolean
      property :read_timeout,      [Fixnum, nil],  default: 60
      property :remove_volumes,    Boolean
      property :restart_maximum_retry_count, Fixnum, default: 0
      property :restart_policy,    String,          default: "no"
      property :security_opts,     [String, Array], default: lazy { [''] }
      property :signal,            String,          default: 'SIGKILL'
      property :stdin_once,        [true, false, nil], default: lazy { !detach }
      property :timeout,           [Fixnum, nil]
      property :tty,               Boolean
      property :ulimits,           [Array, nil],    coerce: (proc do |v|
        if v.nil?
          v
        else
          Array(v).map do |u|
            if u.is_a?(Hash)
              u = "#{u['Name']}=#{u['Soft']}:#{u['Hard']}"
            end
            u
          end
        end
      end)
      property :user,              String,         default: ''
      property :volumes,           [ Hash, nil ],  coerce: (proc do |v|
        case v
        when nil, Hash
          v
        else
          Array(v).inject({}) { |h,volume| h[volume] = {}; h }
        end
      end)
      property :volumes_from,      NullableArray
      property :working_dir,       [String, nil]
      property :write_timeout,     [Fixnum, nil]

      alias_method :cmd, :command
      alias_method :image, :repo
      alias_method :image_name, :repo
      alias_method :additional_host, :extra_hosts
      alias_method :rm, :autoremove
      alias_method :remove_automatically, :autoremove
      alias_method :hostname, :host_name
      alias_method :domainname, :domain_name
      alias_method :dnssearch, :dns_search
      alias_method :restart_maximum_retries, :restart_maximum_retry_count
      alias_method :api_retries, :restart_maximum_retry_count
      alias_method :volume, :volumes
      alias_method :volume_from, :volumes_from
      alias_method :destination, :outfile
      alias_method :workdir, :working_dir

      #########
      # Actions
      #########

      # Super handy visual reference!
      # http://gliderlabs.com/images/docker_events.png

      default_action :run_if_missing

      declare_action_class.class_eval do
        include DockerHelpers::Container
      end

      action :create do
        # Debug logging for things that have given trouble in the past
        Chef::Log.debug("DOCKER: user - current:#{current_resource.user}: desired:#{user}:")
        Chef::Log.debug("DOCKER: working_dir - current:#{current_resource.working_dir}: desired:#{working_dir}:")
        Chef::Log.debug("DOCKER: command - current:#{current_resource.command}: desired:#{command}:")
        Chef::Log.debug("DOCKER: entrypoint - current:#{current_resource.entrypoint}: desired:#{entrypoint}:")
        Chef::Log.debug("DOCKER: env - current:#{current_resource.env}: desired:#{env}:")
        Chef::Log.debug("DOCKER: exposed_ports - current:#{current_resource.exposed_ports}: desired:#{exposed_ports}")
        Chef::Log.debug("DOCKER: volumes - current:#{current_resource.volumes}: desired:#{volumes}:")
        Chef::Log.debug("DOCKER: network_mode - current:#{current_resource.network_mode}: desired:#{network_mode}:")
        Chef::Log.debug("DOCKER: log_config - current:#{current_resource.log_config}: desired:#{log_config}:")
        Chef::Log.debug("DOCKER: ulimits - current:#{current_resource.ulimits}:")
        Chef::Log.debug("DOCKER: ulimits - desired:#{ulimits}:")
        Chef::Log.debug("DOCKER: links - current:#{current_resource.links}: desired:#{links}:")
        Chef::Log.debug("DOCKER: labels - current:#{current_resource.labels}: desired:#{labels}:")

        resource_changes.each do |change|
          Chef::Log.debug("DOCKER: change - :#{change}")
        end

        action_delete unless resource_changes.empty? || !container_created?

        next if container_created?
        converge_by "creating #{container_name}" do
          create_container
        end
      end

      action :start do
        c = Docker::Container.get(container_name, connection)
        next if c.info['State']['Restarting']
        next if c.info['State']['Running']
        converge_by "starting #{container_name}" do
          begin
            tries ||= api_retries

            if detach
              attach_stdin false
              attach_stdout false
              attach_stderr false
              stdin_once false
              c.start
            else
              c.start
              timeout ? c.wait(timeout) : c.wait
            end

          rescue Docker::Error => e
            retry unless (tries -= 1).zero?
            raise e.message
          end
        end
      end

      action :stop do
        next unless container_created?
        c = Docker::Container.get(container_name, connection)
        next unless c.info['State']['Running']
        converge_by "stopping #{container_name}" do
          begin
            tries ||= api_retries
            c.stop
          rescue Docker::Error => e
            retry unless (tries -= 1).zero?
            raise e.message
          end
        end
      end

      action :kill do
        next unless container_created?
        c = Docker::Container.get(container_name, connection)
        next unless c.info['State']['Running']
        converge_by "killing #{container_name}" do
          begin
            tries ||= api_retries
            c.kill(signal: signal)
          rescue Docker::Error => e
            retry unless (tries -= 1).zero?
            raise e.message
          end
        end
      end

      action :run do
        action_create
        action_start
        action_delete if autoremove
      end

      action :run_if_missing do
        next if container_created?
        action_run
      end

      action :pause do
        next unless container_created?
        c = Docker::Container.get(container_name, connection)
        next if c.info['State']['Paused']
        converge_by "pausing #{container_name}" do
          begin
            tries ||= api_retries
            c.pause
          rescue Docker::Error => e
            retry unless (tries -= 1).zero?
            raise e.message
          end
        end
      end

      action :unpause do
        next unless container_created?
        c = Docker::Container.get(container_name, connection)
        next unless c.info['State']['Paused']
        converge_by "unpausing #{container_name}" do
          begin
            tries ||= api_retries
            c.unpause
          rescue Docker::Error => e
            retry unless (tries -= 1).zero?
            raise e.message
          end
        end
      end

      action :restart do
        action_stop
        action_start
      end

      action :redeploy do
        begin
          c = Docker::Container.get(container_name, connection)
          action_delete
          # never start containers resulting from a previous action :create #432
          if c.info['State']['Running'] == false &&
             c.info['State']['StartedAt'] == '0001-01-01T00:00:00Z'
            action_create
          else
            action_run
          end
        rescue Docker::Error::NotFoundError
          action_create
          action_run
        end
      end

      action :delete do
        next unless container_created?
        action_unpause
        action_stop
        c = Docker::Container.get(container_name, connection)
        converge_by "deleting #{container_name}" do
          begin
            tries ||= api_retries
            c.delete(force: force, v: remove_volumes)
          rescue Docker::Error => e
            retry unless (tries -= 1).zero?
            raise e.message
          end
        end
      end

      action :remove do
        action_delete
      end

      action :remove_link do
        # Help! I couldn't get this working from the CLI in docker 1.6.2.
        # It's of dubious usefulness, and it looks like this stuff is
        # changing in 1.7.x anyway.
        converge_by "removing links for #{container_name}" do
          Chef::Log.info(':remove_link not currently implemented')
        end
      end

      action :commit do
        c = Docker::Container.get(container_name, connection)
        converge_by "committing #{container_name}" do
          begin
            tries ||= api_retries
            new_image = c.commit
            new_image.tag('repo' => repo, 'tag' => tag, 'force' => force)
          rescue Docker::Error => e
            retry unless (tries -= 1).zero?
            raise e.message
          end
        end
      end

      action :export do
        fail "Please set outfile property on #{container_name}" if outfile.nil?
        c = Docker::Container.get(container_name, connection)
        converge_by "exporting #{container_name}" do
          begin
            tries ||= api_retries
            ::File.open(outfile, 'w') { |f| c.export { |chunk| f.write(chunk) } }
          rescue Docker::Error => e
            retry unless (tries -= 1).zero?
            raise e.message
          end
        end
      end

      action_class.class_eval do
        def load_current_resource
          @current_resource = Chef::Resource::DockerContainer.new(name)
          begin
            c = Docker::Container.get(container_name, connection)
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
            @current_resource.labels c.info['Config']['Labels']
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
            @current_resource.restart_policy c.info['HostConfig']['RestartPolicy']['Name']
            @current_resource.restart_maximum_retry_count c.info['HostConfig']['RestartPolicy']['MaximumRetryCount']
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
          changes << :attach_stderr if current_resource.attach_stderr != attach_stderr
          changes << :attach_stdin if current_resource.attach_stdin != attach_stdin
          changes << :attach_stdout if current_resource.attach_stdout != attach_stdout
          changes << :binds if current_resource.binds != binds
          changes << :cap_add if current_resource.cap_add != cap_add
          changes << :cap_drop if current_resource.cap_drop != cap_drop
          changes << :cgroup_parent if current_resource.cgroup_parent != cgroup_parent
          changes << :command if update_command?
          changes << :cpu_shares if current_resource.cpu_shares != cpu_shares
          changes << :cpuset_cpus if current_resource.cpuset_cpus != cpuset_cpus
          changes << :devices if current_resource.devices != devices
          changes << :dns if current_resource.dns != dns
          changes << :dns_search if current_resource.dns_search != dns_search
          changes << :domainname if current_resource.domainname != domainname
          changes << :entrypoint if update_entrypoint?
          changes << :env if update_env?
          changes << :exposed_ports if update_exposed_ports?
          changes << :extra_hosts if current_resource.extra_hosts != extra_hosts
          changes << :hostname if update_hostname?
          changes << :image if current_resource.image != "#{repo}:#{tag}"
          changes << :labels if current_resource.labels != labels
          changes << :links if current_resource.links != links
          changes << :log_config if current_resource.log_config != log_config
          changes << :mac_address if current_resource.mac_address != mac_address
          changes << :memory if current_resource.memory != memory
          changes << :memory_swap if current_resource.memory_swap != memory_swap
          changes << :network_disabled if current_resource.network_disabled != network_disabled
          changes << :network_mode if current_resource.network_mode != network_mode
          changes << :open_stdin if current_resource.open_stdin != open_stdin
          changes << :port_bindings if current_resource.port_bindings != port_bindings
          changes << :privileged if current_resource.privileged != privileged
          changes << :publish_all_ports if current_resource.publish_all_ports != publish_all_ports
          changes << :restart_policy if current_resource.restart_policy != restart_policy
          changes << :restart_maximum_retry_count if current_resource.restart_maximum_retry_count != restart_maximum_retry_count
          changes << :stdin_once if current_resource.stdin_once != stdin_once
          changes << :tty if current_resource.tty != tty
          changes << :ulimits if update_ulimits?
          changes << :user if current_resource.user != user
          changes << :volumes if update_volumes?
          changes << :volumes_from if current_resource.volumes_from != volumes_from
          changes << :working_dir if update_working_dir?
          changes
        end

        # Most important work is done here.
        def create_container
          tries ||= api_retries
          Docker::Container.create(
            {
              'name' => container_name,
              'Image' => "#{repo}:#{tag}",
              'Labels' => labels,
              'Cmd' => Shellwords.shellwords(command),
              'AttachStderr' => attach_stderr,
              'AttachStdin' => attach_stdin,
              'AttachStdout' => attach_stdout,
              'Domainname' => domain_name,
              'Entrypoint' => Shellwords.shellwords(entrypoint),
              'Env' => env,
              'ExposedPorts' => exposed_ports,
              'Hostname' => host_name,
              'MacAddress' => mac_address,
              'NetworkDisabled' => network_disabled,
              'OpenStdin' => open_stdin,
              'StdinOnce' => stdin_once,
              'Tty' => tty,
              'User' => user,
              'Volumes' => volumes,
              'WorkingDir' => working_dir,
              'HostConfig' => {
                'Binds' => binds,
                'CapAdd' => cap_add,
                'CapDrop' => cap_drop,
                'CgroupParent' => cgroup_parent,
                'CpuShares' => cpu_shares,
                'CpusetCpus' => cpuset_cpus,
                'Devices' => devices,
                'Dns' => dns,
                'DnsSearch' => dns_search,
                'ExtraHosts' => extra_hosts,
                'Links' => links,
                'LogConfig' => log_config,
                'Memory' => memory,
                'MemorySwap' => memory_swap,
                'NetworkMode' => network_mode,
                'Privileged' => privileged,
                'PortBindings' => port_bindings,
                'PublishAllPorts' => publish_all_ports,
                'RestartPolicy' => {
                  "Name" => restart_policy,
                  "MaximumRetryCount" => restart_maximum_retry_count
                },
                'Ulimits' => ulimits_to_hash,
                'VolumesFrom' => volumes_from
              }
            }, connection)
        rescue Docker::Error => e
          retry unless (tries -= 1).zero?
          raise e.message
        end
      end

      def ulimits_to_hash
        return nil if ulimits.nil?
        ulimits.map do |u|
          name = u.split('=')[0]
          soft = u.split('=')[1].split(':')[0]
          hard = u.split('=')[1].split(':')[1]
          { 'Name' => name, 'Soft' => soft.to_i, 'Hard' => hard.to_i }
        end
      end
    end
  end
end
