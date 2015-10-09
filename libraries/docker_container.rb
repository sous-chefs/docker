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
      property :dns_search,        ArrayType
      property :domain_name,       String,        default: ''
      property :entrypoint,        ShellCommand
      property :env,               SortedArray
      property :extra_hosts,       NonEmptyArray
      property :exposed_ports,     [Hash, nil]
      property :force,             Boolean
      property :host,              [String, nil]
      property :host_name,         [String, nil]
      property :labels,            [Hash, nil],   coerce: (proc do |v|
        case v
        when Hash, nil
          v
        else
          Array(v).each_with_object({}) do |label, h|
            parts = label.split(':')
            h[parts[0]] = parts[1]
          end
        end
      end)
      property :links,             [Array, nil],  coerce: (proc do |v|
        v = Array(v)
        if v.empty?
          nil
        else
          # Parse docker input of /source:/container_name/dest into source:dest
          v.map do |link|
            if link =~ %r{^/(?<source>.+):/#{name}/(?<dest>.+)}
              link = "#{Regexp.last_match[:source]}:#{Regexp.last_match[:dest]}"
            end
            link
          end
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
      property :remove_volumes,    Boolean
      property :restart_maximum_retry_count, Fixnum, default: 0
      property :restart_policy,    String,          default: 'no'
      property :security_opts,     [String, Array], default: lazy { [''] }
      property :signal,            String,          default: 'SIGKILL'
      property :stdin_once,        [Boolean, nil],  default: lazy { !detach }
      property :timeout,           [Fixnum, nil]
      property :tty,               Boolean
      property :ulimits,           [Array, nil],    coerce: (proc do |v|
        if v.nil?
          v
        else
          Array(v).map do |u|
            u = "#{u['Name']}=#{u['Soft']}:#{u['Hard']}" if u.is_a?(Hash)
            u
          end
        end
      end)
      property :user,              String,         default: ''
      property :volumes,           [Hash, nil],    coerce: (proc do |v|
        case v
        when nil, Hash
          v
        else
          Array(v).sort.each_with_object({}) { |volume, h| h[volume] = {} }
        end
      end)
      property :volumes_from,      ArrayType
      property :working_dir,       [String, nil]

      # Used to store the state of the Docker container
      property :container,         Docker::Container
      property :state,             Hash,            default: lazy { container.info['State'] }

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

        def call_action(action)
          send("action_#{action}")
          load_current_resource
        end
      end

      action :create do
        converge_if_changed do
          call_action(:delete)

          with_retries do
            Docker::Container.create(
              {
                'name'            => container_name,
                'Image'           => "#{repo}:#{tag}",
                'Labels'          => labels,
                'Cmd'             => to_shellwords(command),
                'AttachStderr'    => attach_stderr,
                'AttachStdin'     => attach_stdin,
                'AttachStdout'    => attach_stdout,
                'Domainname'      => domain_name,
                'Entrypoint'      => to_shellwords(entrypoint),
                'Env'             => env,
                'ExposedPorts'    => exposed_ports,
                'Hostname'        => host_name,
                'MacAddress'      => mac_address,
                'NetworkDisabled' => network_disabled,
                'OpenStdin'       => open_stdin,
                'StdinOnce'       => stdin_once,
                'Tty'             => tty,
                'User'            => user,
                'Volumes'         => volumes,
                'WorkingDir'      => working_dir,
                'HostConfig'      => {
                  'Binds'           => binds,
                  'CapAdd'          => cap_add,
                  'CapDrop'         => cap_drop,
                  'CgroupParent'    => cgroup_parent,
                  'CpuShares'       => cpu_shares,
                  'CpusetCpus'      => cpuset_cpus,
                  'Devices'         => devices,
                  'Dns'             => dns,
                  'DnsSearch'       => dns_search,
                  'ExtraHosts'      => extra_hosts,
                  'Links'           => links,
                  'LogConfig'       => log_config,
                  'Memory'          => memory,
                  'MemorySwap'      => memory_swap,
                  'NetworkMode'     => network_mode,
                  'Privileged'      => privileged,
                  'PortBindings'    => port_bindings,
                  'PublishAllPorts' => publish_all_ports,
                  'RestartPolicy'   => {
                    'Name'              => restart_policy,
                    'MaximumRetryCount' => restart_maximum_retry_count
                  },
                  'Ulimits'         => ulimits_to_hash,
                  'VolumesFrom'     => volumes_from
                }
              }, connection)
          end
        end
      end

      action :start do
        return if state['Restarting']
        return if state['Running']
        converge_by "starting #{container_name}" do
          with_retries do
            if detach
              attach_stdin false
              attach_stdout false
              attach_stderr false
              stdin_once false
              container.start
            else
              container.start
              timeout ? container.wait(timeout) : container.wait
            end
          end
        end
      end

      action :stop do
        return unless state['Running']
        converge_by "stopping #{container_name}" do
          with_retries { container.stop }
        end
      end

      action :kill do
        return unless state['Running']
        converge_by "killing #{container_name}" do
          with_retries { container.kill(signal: signal) }
        end
      end

      action :run do
        call_action(:create)
        call_action(:start)
        call_action(:delete) if autoremove
      end

      action :run_if_missing do
        return if current_resource
        call_action(:run)
      end

      action :pause do
        return if state['Paused']
        converge_by "pausing #{container_name}" do
          with_retries { container.pause }
        end
      end

      action :unpause do
        return if current_resource && !state['Paused']
        converge_by "unpausing #{container_name}" do
          with_retries { container.unpause }
        end
      end

      action :restart do
        call_action(:stop)
        call_action(:start)
      end

      action :redeploy do
        if current_resource
          call_action(:delete)
          # never start containers resulting from a previous action :create #432
          if state['Running'] == false &&
             state['StartedAt'] == '0001-01-01T00:00:00Z'
            call_action(:create)
          else
            call_action(:run)
          end
        else
          call_action(:create)
          call_action(:run)
        end
      end

      action :delete do
        return unless current_resource
        call_action(:unpause)
        call_action(:stop)
        converge_by "deleting #{container_name}" do
          with_retries { container.delete(force: force, v: remove_volumes) }
        end
      end

      action :remove do
        call_action(:delete)
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
        converge_by "committing #{container_name}" do
          with_retries do
            new_image = container.commit
            new_image.tag('repo' => repo, 'tag' => tag, 'force' => force)
          end
        end
      end

      action :export do
        fail "Please set outfile property on #{container_name}" if outfile.nil?
        converge_by "exporting #{container_name}" do
          with_retries do
            ::File.open(outfile, 'w') { |f| container.export { |chunk| f.write(chunk) } }
          end
        end
      end

      load_current_value do
        begin
          with_retries { container Docker::Container.get(container_name, connection) }
        rescue Docker::Error::NotFoundError
          current_value_does_not_exist!
        end

        # Go through everything in the container and set corresponding properties:
        # c.info['Config']['ExposedPorts'] -> exposed_ports
        (container.info['Config'].to_a + container.info['HostConfig'].to_a).each do |key, value|
          next if value.nil? || key == 'RestartPolicy'
          # Set exposed_ports = ExposedPorts
          property_name = to_snake_case(key)
          public_send(property_name, value) if respond_to?(property_name)
        end

        # RestartPolicy is a special case for us because our names differ from theirs
        restart_policy container.info['HostConfig']['RestartPolicy']['Name']
        restart_maximum_retry_count container.info['HostConfig']['RestartPolicy']['MaximumRetryCount']
      end

      def to_snake_case(name)
        # ExposedPorts -> _exposed_ports
        name = name.gsub(/[A-Z]/) { |x| "_#{x.downcase}" }
        # _exposed_ports -> exposed_ports
        name = name[1..-1] if name.start_with?('_')
        name
      end

      def to_shellwords(command)
        return nil if command.nil?
        Shellwords.shellwords(command)
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
