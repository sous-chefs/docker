module DockerCookbook
  class DockerContainer < DockerBase
    require 'docker'
    require 'shellwords'
    require_relative 'helpers_container'

    include DockerHelpers::Container

    resource_name :docker_container

    # The non-standard types Boolean, ArrayType, ShellCommand, etc
    # are found in the DockerBase class.
    property :container_name, String, name_property: true
    property :repo, String, default: lazy { container_name }
    property :tag, String, default: 'latest'
    property :command, ShellCommand
    property :attach_stderr, Boolean, default: false, desired_state: false
    property :attach_stdin, Boolean, default: false, desired_state: false
    property :attach_stdout, Boolean, default: false, desired_state: false
    property :autoremove, Boolean, desired_state: false
    property :cap_add, NonEmptyArray
    property :cap_drop, NonEmptyArray
    property :cgroup_parent, String, default: ''
    property :cpu_shares, [Integer, nil], default: 0
    property :cpuset_cpus, String, default: ''
    property :detach, Boolean, default: true, desired_state: false
    property :devices, Array, default: []
    property :dns, Array, default: []
    property :dns_search, Array, default: []
    property :domain_name, String, default: ''
    property :entrypoint, ShellCommand
    property :env, UnorderedArrayType, default: []
    property :extra_hosts, NonEmptyArray
    property :exposed_ports, PartialHashType, default: {}
    property :force, Boolean, desired_state: false
    property :host, [String, nil], default: lazy { default_host }, desired_state: false
    property :hostname, String
    property :ipc_mode, String, default: ''
    property :kernel_memory, [String, Integer], coerce: proc { |v| coerce_kernel_memory(v) }, default: 0
    property :labels, [String, Array, Hash], default: {}, coerce: proc { |v| coerce_labels(v) }
    property :links, UnorderedArrayType, coerce: proc { |v| coerce_links(v) }
    property :log_driver, %w( json-file syslog journald gelf fluentd awslogs splunk etwlogs gcplogs none ), default: 'json-file', desired_state: false
    property :log_opts, [Hash, nil], coerce: proc { |v| coerce_log_opts(v) }, desired_state: false
    property :ip_address, String
    property :mac_address, String
    property :memory, [String, Integer], coerce: proc { |v| coerce_memory(v) }, default: 0
    property :memory_swap, [String, Integer], coerce: proc { |v| coerce_memory_swap(v) }, default: 0
    property :memory_swappiness, Integer, coerce: proc { |v| coerce_memory_swappiness(v) }, default: 0
    property :memory_reservation, Integer, coerce: proc { |v| coerce_memory_reservation(v) }, default: 0
    property :network_disabled, Boolean, default: false
    property :network_mode, [String, NilClass], default: 'bridge'
    property :network_aliases, [ArrayType], default: []
    property :open_stdin, Boolean, default: false, desired_state: false
    property :outfile, [String, NilClass]
    property :port_bindings, PartialHashType, default: {}
    property :pid_mode, String, default: ''
    property :privileged, Boolean, default: false
    property :publish_all_ports, Boolean, default: false
    property :remove_volumes, Boolean
    property :restart_maximum_retry_count, Integer, default: 0
    property :restart_policy, String
    property :ro_rootfs, Boolean, default: false
    property :security_opt, [String, ArrayType]
    property :signal, String, default: 'SIGTERM'
    property :stdin_once, Boolean, default: false, desired_state: false
    property :sysctls, Hash, default: {}
    property :timeout, [Integer, nil], desired_state: false
    property :tty, Boolean, default: false
    property :ulimits, [Array, nil], coerce: proc { |v| coerce_ulimits(v) }
    property :user, String, default: ''
    property :userns_mode, String, default: ''
    property :uts_mode, String, default: ''
    property :volumes, PartialHashType, default: {}, coerce: proc { |v| coerce_volumes(v) }
    property :volumes_from, ArrayType
    property :volume_driver, String
    property :working_dir, [String, NilClass], default: ''

    # Used to store the bind property since binds is an alias to volumes
    property :volumes_binds, Array

    # Used to store the state of the Docker container
    property :container, Docker::Container, desired_state: false

    # Used by :stop action. If the container takes longer than this
    # many seconds to stop, kill it instead. A nil value (the default) means
    # never kill the container.
    property :kill_after, [Integer, NilClass], default: nil, desired_state: false

    alias cmd command
    alias additional_host extra_hosts
    alias rm autoremove
    alias remove_automatically autoremove
    alias host_name hostname
    alias domainname domain_name
    alias dnssearch dns_search
    alias restart_maximum_retries restart_maximum_retry_count
    alias volume volumes
    alias binds volumes
    alias volume_from volumes_from
    alias destination outfile
    alias workdir working_dir

    # ~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~
    # Begin classic Chef "provider" section
    # ~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~

    ########################################################
    # Load Current Value
    ########################################################

    load_current_value do
      # Grab the container and assign the container property
      begin
        with_retries { container Docker::Container.get(container_name, {}, connection) }
      rescue Docker::Error::NotFoundError
        current_value_does_not_exist!
      end

      # Go through everything in the container and set corresponding properties:
      # c.info['Config']['ExposedPorts'] -> exposed_ports
      (container.info['Config'].to_a + container.info['HostConfig'].to_a).each do |key, value|
        next if value.nil? || key == 'RestartPolicy' || key == 'Binds' || key == 'ReadonlyRootfs'

        # Image => image
        # Set exposed_ports = ExposedPorts (etc.)
        property_name = to_snake_case(key)
        public_send(property_name, value) if respond_to?(property_name)
      end

      # load container specific labels (without engine/image ones)
      load_container_labels

      # these are a special case for us because our names differ from theirs
      restart_policy container.info['HostConfig']['RestartPolicy']['Name']
      restart_maximum_retry_count container.info['HostConfig']['RestartPolicy']['MaximumRetryCount']
      volumes_binds container.info['HostConfig']['Binds']
      ro_rootfs container.info['HostConfig']['ReadonlyRootfs']
    end

    #########
    # Actions
    #########

    # Super handy visual reference!
    # http://gliderlabs.com/images/docker_events.png

    default_action :run

    declare_action_class.class_eval do
      def whyrun_supported?
        true
      end

      def call_action(action)
        send("action_#{action}")
        load_current_resource
      end

      def state
        current_resource ? current_resource.state : {}
      end
    end

    # Loads container specific labels excluding those of engine or image.
    # This insures idempotency.
    def load_container_labels
      image_labels = Docker::Image.get(container.info['Image'], {}, connection).info['Config']['Labels'] || {}
      engine_labels = Docker.info(connection)['Labels'] || {}

      labels = (container.info['Config']['Labels'] || {}).reject do |key, val|
        image_labels.any? { |k, v| k == key && v == val } ||
          engine_labels.any? { |k, v| k == key && v == val }
      end

      public_send(:labels, labels)
    end

    def validate_container_create
      if property_is_set?(:restart_policy) &&
         restart_policy != 'no' &&
         restart_policy != 'always' &&
         restart_policy != 'unless-stopped' &&
         restart_policy != 'on-failure'
        raise Chef::Exceptions::ValidationFailed, 'restart_policy must be either no, always, unless-stopped, or on-failure.'
      end

      if autoremove == true && (property_is_set?(:restart_policy) && restart_policy != 'no')
        raise Chef::Exceptions::ValidationFailed, 'Conflicting options restart_policy and autoremove.'
      end

      if detach == true &&
         (
          attach_stderr == true ||
          attach_stdin == true ||
          attach_stdout == true ||
          stdin_once == true
         )
        raise Chef::Exceptions::ValidationFailed, 'Conflicting options detach, attach_stderr, attach_stdin, attach_stdout, stdin_once.'
      end

      if network_mode == 'host' &&
         (
          !(hostname.nil? || hostname.empty?) ||
          !(mac_address.nil? || mac_address.empty?)
         )
        raise Chef::Exceptions::ValidationFailed, 'Cannot specify hostname or mac_address when network_mode is host.'
      end

      if network_mode == 'container' &&
         (
          !(hostname.nil? || hostname.empty?) ||
          !(dns.nil? || dns.empty?) ||
          !(dns_search.nil? || dns_search.empty?) ||
          !(mac_address.nil? || mac_address.empty?) ||
          !(extra_hosts.nil? || extra_hosts.empty?) ||
          !(exposed_ports.nil? || exposed_ports.empty?) ||
          !(port_bindings.nil? || port_bindings.empty?) ||
          !(publish_all_ports.nil? || publish_all_ports.empty?) ||
          !port.nil?
         )
        raise Chef::Exceptions::ValidationFailed, 'Cannot specify hostname, dns, dns_search, mac_address, extra_hosts, exposed_ports, port_bindings, publish_all_ports, port when network_mode is container.'
      end
    end

    def parsed_hostname
      return nil if network_mode == 'host'
      hostname
    end

    action :create do
      validate_container_create

      converge_if_changed do
        action_delete

        with_retries do
          config = {
            'name'            => new_resource.container_name,
            'Image'           => "#{new_resource.repo}:#{new_resource.tag}",
            'Labels'          => new_resource.labels,
            'Cmd'             => to_shellwords(new_resource.command),
            'AttachStderr'    => new_resource.attach_stderr,
            'AttachStdin'     => new_resource.attach_stdin,
            'AttachStdout'    => new_resource.attach_stdout,
            'Domainname'      => new_resource.domain_name,
            'Entrypoint'      => to_shellwords(new_resource.entrypoint),
            'Env'             => new_resource.env,
            'ExposedPorts'    => new_resource.exposed_ports,
            'Hostname'        => parsed_hostname,
            'MacAddress'      => new_resource.mac_address,
            'NetworkDisabled' => new_resource.network_disabled,
            'OpenStdin'       => new_resource.open_stdin,
            'StdinOnce'       => new_resource.stdin_once,
            'Tty'             => new_resource.tty,
            'User'            => new_resource.user,
            'Volumes'         => new_resource.volumes,
            'WorkingDir'      => new_resource.working_dir,
            'HostConfig'      => {
              'Binds'           => new_resource.volumes_binds,
              'CapAdd'          => new_resource.cap_add,
              'CapDrop'         => new_resource.cap_drop,
              'CgroupParent'    => new_resource.cgroup_parent,
              'CpuShares'       => new_resource.cpu_shares,
              'CpusetCpus'      => new_resource.cpuset_cpus,
              'Devices'         => new_resource.devices,
              'Dns'             => new_resource.dns,
              'DnsSearch'       => new_resource.dns_search,
              'ExtraHosts'      => new_resource.extra_hosts,
              'IpcMode'         => new_resource.ipc_mode,
              'KernelMemory'    => new_resource.kernel_memory,
              'Links'           => new_resource.links,
              'LogConfig'       => log_config,
              'Memory'          => new_resource.memory,
              'MemorySwap'      => new_resource.memory_swap,
              'MemorySwappiness' => new_resource.memory_swappiness,
              'MemoryReservation' => new_resource.memory_reservation,
              'NetworkMode'     => new_resource.network_mode,
              'Privileged'      => new_resource.privileged,
              'PidMode'         => new_resource.pid_mode,
              'PortBindings'    => new_resource.port_bindings,
              'PublishAllPorts' => new_resource.publish_all_ports,
              'RestartPolicy'   => {
                'Name'              => new_resource.restart_policy,
                'MaximumRetryCount' => new_resource.restart_maximum_retry_count,
              },
              'ReadonlyRootfs'  => new_resource.ro_rootfs,
              'SecurityOpt'     => new_resource.security_opt,
              'Sysctls'         => new_resource.sysctls,
              'Ulimits'         => new_resource.ulimits_to_hash,
              'UsernsMode'      => new_resource.userns_mode,
              'UTSMode'         => new_resource.uts_mode,
              'VolumesFrom'     => new_resource.volumes_from,
              'VolumeDriver'    => new_resource.volume_driver,
            },
          }
          net_config = {
            'NetworkingConfig' => {
              'EndpointsConfig' => {
                new_resource.network_mode => {
                  'IPAMConfig' => {
                    'IPv4Address' => new_resource.ip_address,
                  },
                  'Aliases' => new_resource.network_aliases,
                },
              },
            },
          } if new_resource.network_mode
          config.merge! net_config

          Docker::Container.create(config, connection)
        end
      end
    end

    action :start do
      return if state['Restarting']
      return if state['Running']
      converge_by "starting #{new_resource.container_name}" do
        with_retries do
          current_resource.container.start
          timeout ? container.wait(timeout) : container.wait unless new_resource.detach
        end
        wait_running_state(true) if new_resource.detach
      end
    end

    action :stop do
      return unless state['Running']
      kill_after_str = "(will kill after #{new_resource.kill_after}s)" if new_resource.kill_after
      converge_by "stopping #{new_resource.container_name} #{kill_after_str}" do
        begin
          with_retries do
            current_resource.container.stop!('timeout' => new_resource.kill_after)
            wait_running_state(false)
          end
        rescue Docker::Error::TimeoutError
          raise Docker::Error::TimeoutError, "Container failed to stop, consider adding kill_after to the container #{new_resource.container_name}"
        end
      end
    end

    action :kill do
      return unless state['Running']
      converge_by "killing #{new_resource.container_name}" do
        with_retries { current_resource.container.kill(signal: new_resource.signal) }
      end
    end

    action :run do
      validate_container_create
      call_action(:create)
      call_action(:start)
      call_action(:delete) if new_resource.autoremove
    end

    action :run_if_missing do
      return if current_resource
      call_action(:run)
    end

    action :pause do
      return if state['Paused']
      converge_by "pausing #{new_resource.container_name}" do
        with_retries { current_resource.container.pause }
      end
    end

    action :unpause do
      return if current_resource && !state['Paused']
      converge_by "unpausing #{new_resource.container_name}" do
        with_retries { current_resource.container.unpause }
      end
    end

    action :restart do
      kill_after_str = " (will kill after #{new_resource.kill_after}s)" if new_resource.kill_after != -1
      converge_by "restarting #{new_resource.container_name} #{kill_after_str}" do
        current_resource ? current_resource.container.restart('timeout' => new_resource.kill_after) : call_action(:run)
      end
    end

    action :reload do
      converge_by "reloading #{new_resource.container_name}" do
        with_retries { container.kill(signal: 'SIGHUP') }
      end
    end

    action :redeploy do
      validate_container_create

      # never start containers resulting from a previous action :create #432
      should_create = state['Running'] == false && state['StartedAt'] == '0001-01-01T00:00:00Z'
      call_action(:delete)
      call_action(should_create ? :create : :run)
    end

    action :delete do
      return unless current_resource
      call_action(:unpause)
      call_action(:stop)
      converge_by "deleting #{new_resource.container_name}" do
        with_retries { current_resource.container.delete(force: new_resource.force, v: new_resource.remove_volumes) }
      end
    end

    action :remove do
      call_action(:delete)
    end

    action :commit do
      converge_by "committing #{new_resource.container_name}" do
        with_retries do
          new_image = current_resource.container.commit
          new_image.tag('repo' => new_resource.repo, 'tag' => new_resource.tag, 'force' => new_resource.force)
        end
      end
    end

    action :export do
      raise "Please set outfile property on #{new_resource.container_name}" if new_resource.outfile.nil?
      converge_by "exporting #{new_resource.container_name}" do
        with_retries do
          ::File.open(new_resource.outfile, 'w') { |f| current_resource.container.export { |chunk| f.write(chunk) } }
        end
      end
    end
  end
end
