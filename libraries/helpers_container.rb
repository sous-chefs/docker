module DockerHelpers
  module Container
    ################
    # Helper methods
    ################

    # This is called a lot.. maybe this should turn into an instance variable
    def container_created?
      Docker::Container.get(container_name, connection)
      return true
    rescue Docker::Error::NotFoundError
      return false
    end

    # 22/tcp, 53/udp, etc
    def exposed_ports
      return nil if ports.empty?
      ports.inject({}) { |a, e| expand_port_exposure(a, e) }
    end

    def expand_port_exposure(exposings, value)
      exposings.merge(PortBinding.new(value).exposure)
    end

    # Map container exposed port to the host
    def port_bindings
      return nil if ports.empty?
      ports.inject({}) { |a, e| expand_port_binding(a, e) }
    end

    def expand_port_binding(binds, value)
      binds.merge(PortBinding.new(value).binding)
    end

    def dns_search
      return nil if dns_search.nil?
      Array(dns_search)
    end

    # There is no way to determine if these values originated from
    # an image build, or from a previous chef-client run. Therefore,
    # we need to treat them as "unmanaged" in the event they're not
    # specified on the resource.

    def update_command?
      return true unless command.nil? || command == '' || (current_resource.command == command)
      false
    end

    def update_user?
      return true unless user.nil? || (current_resource.user == user)
      false
    end

    def update_env?
      return false if env.nil?
      return false if current_resource.env.nil?
      return true unless env.each { |v| current_resource.env.include?(v) }
      false
    end

    def update_entrypoint?
      return false if entrypoint.nil?
      return false if entrypoint.empty?
      return true if current_resource.entrypoint != entrypoint
      false
    end

    def update_volumes?
      return false if volumes.nil?
      return true if current_resource.volumes.nil?
      return true unless volumes.each { |v| current_resource.volumes.include?(v) }
      false
    end

    def update_working_dir?
      return false if working_dir.nil?
      return true if current_resource.working_dir != working_dir
      false
    end

    def update_ulimits?
      return false if ulimits.nil?
      return true if current_resource.ulimits != ulimits
      false
    end

    def update_hostname?
      return false if network_mode == 'host'
      return true if (!hostname.nil?) && (current_resource.hostname != hostname)
      false
    end

    def update_exposed_ports?
      return false if exposed_ports.nil?
      return true if current_resource.exposed_ports != exposed_ports
      false
    end
  end
end
