module DockerHelpers
  module Container
    ################
    # Helper methods
    ################

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

    def default_labels
      case v
      when Hash, nil
        v
      else
        Array(v).each_with_object({}) do |label, h|
          parts = label.split(':')
          h[parts[0]] = parts[1]
        end
      end
    end
  end
end
