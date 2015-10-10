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
      property :env,               UnorderedArrayType
      property :extra_hosts,       NonEmptyArray
      property :exposed_ports,     [Hash, nil]
      property :force,             Boolean
      property :host,              [String, nil], desired_state: false
      property :hostname,          [String, nil]
      property :labels,            [Hash, nil],   coerce: proc { |v| coerce_labels(v) }
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
      property :outfile,           [String, nil],   default: nil
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
      property :container,         Docker::Container, desired_state: false
      # If the container takes longer than this many seconds to stop, kill it instead.
      # -1 (the default) means never kill the container.
      property :kill_after,        Numeric, default: -1, desired_state: false

      def state
        container ? container.info['State'] : {}
      end

      # port_bindings and exposed_ports really handle this
      # TODO infer `port` from `port_bindings` and `exposed_ports`
      def port(ports=NOT_PASSED)
        if ports != NOT_PASSED
          ports = Array(ports)
          ports = nil if ports.empty?
          @port = ports
          port_bindings to_port_bindings(ports)
          exposed_ports to_port_exposures(ports)
        end
        @port
      end

      # log_driver and log_opts really handle this
      def log_config(value=NOT_PASSED)
        if value != NOT_PASSED
          @log_config = value
          log_driver value['Type']
          log_opts value['Config']
        end
        return @log_config if defined?(@log_config)
        default = {}
        default['Type'] = log_driver if property_is_set?(:log_driver)
        default['Config'] = log_opts if property_is_set?(:log_opts)
        default = nil if default.empty?
        default
      end

      #
      # TODO: test image property in serverspec and kitchen
      #
      # If you say:    `repo 'blah'`
      # Image will be: `blah:latest`
      #
      # If you say:    `repo 'blah'; tag '3.1'`
      # Image will be: `blah:3.1`
      #
      # If you say:    `image 'blah'`
      # Repo will be:  `blah`
      # Tag will be:   `latest`
      #
      # If you say:    `image 'blah:3.1'`
      # Repo will be:  `blah`
      # Tag will be:   `3.1`
      #
      def image(image=nil)
        if image
          r, t = image.split(':', 2)
          repo r
          tag t if t
        end
        "#{repo}:#{tag}"
      end

      alias_method :cmd, :command
      alias_method :image_name, :image
      alias_method :additional_host, :extra_hosts
      alias_method :rm, :autoremove
      alias_method :remove_automatically, :autoremove
      alias_method :host_name, :hostname
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

      include DockerHelpers::Container

      declare_action_class.class_eval do
        def call_action(action)
          send("action_#{action}")
          load_current_resource
        end
        def state
          current_resource ? current_resource.state : {}
        end
      end

      def validate_container_create
        if network_mode == 'host' && property_is_set?(:hostname)
          raise Chef::Exceptions::ValidationFailed, "Cannot specify hostname on #{container_name}, because network_mode is host."
        end
      end

      action :create do
        validate_container_create

        converge_if_changed do
          action_delete

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
                'Hostname'        => hostname,
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
        kill_after_str = " (will kill after #{kill_after}s)" if kill_after != -1
        converge_by "stopping #{container_name}#{kill_after_str}" do
          with_retries { container.stop!('t' => kill_after) }
        end
      end

      action :kill do
        return unless state['Running']
        converge_by "killing #{container_name}" do
          with_retries { container.kill(signal: signal) }
        end
      end

      action :run do
        validate_container_create
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
        # TODO there is a restart endpoint
        call_action(:stop)
        call_action(:start)
      end

      action :redeploy do
        validate_container_create

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
        # Grab the container and assign the container property
        begin
          with_retries { container Docker::Container.get(container_name, connection) }
        rescue Docker::Error::NotFoundError
          current_value_does_not_exist!
        end

        # Go through everything in the container and set corresponding properties:
        # c.info['Config']['ExposedPorts'] -> exposed_ports
        (container.info['Config'].to_a + container.info['HostConfig'].to_a).each do |key, value|
          next if value.nil? || key == 'RestartPolicy'
          # Image => image
          # Set exposed_ports = ExposedPorts (etc.)
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
