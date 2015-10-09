module DockerHelpers
  module Container
    ################
    # Helper methods
    ################

    def to_port_exposures(ports)
      return nil if ports.nil?
      Array(ports).inject({}) { |h, port| h.merge(PortBinding.new(port).exposure) }
    end

    def to_port_bindings(ports)
      return nil if ports.nil?
      Array(ports).inject({}) { |h, port| h.merge(PortBinding.new(port).binding) }
    end

    def coerce_labels(v)
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
