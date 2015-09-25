# -*- coding: utf-8 -*-

module DockerHelpers
  module Container
    ################
    # Helper methods
    ################

    def api_timeouts
      Docker.options[:read_timeout] = new_resource.read_timeout unless new_resource.read_timeout.nil?
      Docker.options[:write_timeout] = new_resource.write_timeout unless new_resource.write_timeout.nil?
    end

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

    def parsed_entrypoint
      return nil if new_resource.entrypoint.nil?
      ::Shellwords.shellwords(new_resource.entrypoint)
    end

    def parsed_attach_stderr
      return false if new_resource.detach
      return new_resource.attach_stderr if new_resource.attach_stderr
      true
    end

    def parsed_attach_stdin
      return false if new_resource.detach
      return new_resource.attach_stdin if new_resource.attach_stdin
      false
    end

    def parsed_attach_stdout
      return false if new_resource.detach
      return new_resource.attach_stdout if new_resource.attach_stdout
      true
    end

    def parsed_stdin_once
      return false if new_resource.detach
      return new_resource.stdin_once if new_resource.stdin_once
      false
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

    # As of Docker 1.8.1, The API wants the 'source:alias' format as input
    # and returns this at output. Use this to look for changes.
    def serialized_links
      return nil if new_resource.links.nil?
      return nil if new_resource.links.empty?
      ray = []
      Array(new_resource.links).each do |link|
        parts = link.split(':')
        ray << "/#{parts[0]}:/#{new_resource.name}/#{parts[1]}"
      end
      ray
    end

    def parsed_log_config
      (new_resource.log_config || {}).tap do |log_config|
        # some versions of docker api do not support config attributes, then
        # nil is used. Unclear which version since 1.18 and 1.20 feature a
        # Config hash in the documentation while 1.19 has ambiguous example.
        log_config['Type'] ||= 'json-file'
        log_config['Config'] ||= {}
      end
    end

    def parsed_log_opts
      Array(new_resource.log_opts).each_with_object({}) do |log_opt, memo|
        key, value = log_opt.split('=', 2)
        memo[key] = value
      end
    end

    def serialized_log_config
      parsed_log_config.tap do |log_config|
        log_config['Type'] = new_resource.log_driver if new_resource.log_driver
        log_config['Config'] = parsed_log_opts if new_resource.log_opts
      end
    end

    def parsed_network_mode
      return new_resource.network_mode if new_resource.network_mode
      case @api_version
      when '1.20'
        return 'default'
      when '1.19'
        return 'bridge'
      else
        return ''
      end
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

    # There is no way to determine if these values originated from
    # an image build, or from a previous chef-client run. Therefore,
    # we need to treat them as "unmanaged" in the event they're not
    # specified on the resource.

    def update_command?
      return true unless parsed_command.empty? || (current_resource.command == parsed_command)
      false
    end

    def update_user?
      return true unless parsed_user.nil? || (current_resource.user == new_resource.user)
      false
    end

    def parsed_ulimits
      return Array(new_resource.ulimits) if new_resource.ulimits
      return nil if new_resource.ulimits.nil?
    end

    def serialized_ulimits
      # If supplied in Hash format, use that
      return nil if parsed_ulimits.nil?
      return parsed_ulimits if parsed_ulimits[0].class == Hash
      # Otherwise, parse Docker CLI formatted strings into Hashes
      ray = []
      parsed_ulimits.each do |u|
        name = u.split('=')[0]
        soft = u.split('=')[1].split(':')[0]
        hard = u.split('=')[1].split(':')[1]
        ray << { 'Name' => name, 'Soft' => soft.to_i, 'Hard' => hard.to_i }
      end
      ray
    end

    def update_env?
      return false if parsed_env.nil?
      return false if current_resource.env.nil?
      return true unless parsed_env.each { |v| current_resource.env.include?(v) }
      false
    end

    def update_entrypoint?
      return false if parsed_entrypoint.nil?
      return false if parsed_entrypoint.empty?
      return true if current_resource.entrypoint != parsed_entrypoint
      false
    end

    def update_volumes?
      return false if parsed_volumes.nil?
      return true if current_resource.volumes.nil?
      return true unless parsed_volumes.each { |v| current_resource.volumes.include?(v) }
      false
    end

    def update_working_dir?
      return false if new_resource.working_dir.nil?
      return true if current_resource.working_dir != new_resource.working_dir
      false
    end

    def update_ulimits?
      return false if parsed_ulimits.nil?
      return true if current_resource.ulimits != serialized_ulimits
      false
    end

    def update_hostname?
      return false if new_resource.network_mode == 'host'
      return true if (!new_resource.hostname.nil?) && (current_resource.hostname != new_resource.hostname)
      false
    end

    def update_exposed_ports?
      return false if new_resource.exposed_ports.nil?
      return true if current_resource.exposed_ports != new_resource.exposed_ports
      false
    end
  end
end
