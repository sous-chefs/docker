class PortBinding
  attr_reader :host_ip, :host_port, :container_port

  def initialize(value)
    @definition = value
    @host_ip = ''
    @host_port = ''
    @container_port = ''
    parse(value)
  end

  def binding
    {
      container_port.to_s => [
        {
          'HostIp' => host_ip,
          'HostPort' => host_port
        }
      ]
    }
  end

  def exposure
    { container_port.to_s => {} }
  end

  def to_s
    @definition
  end

  private

  def parse(value)
    parts = value.split(':')
    case parts.length
    when 3
      @host_ip = parts[0]
      @host_port = parts[1]
      @container_port = parts[2]
    when 2
      @host_ip = '0.0.0.0'
      @host_port = parts[0]
      @container_port = parts[1]
    when 1
      @container_port = parts[0]
    end
    # qualify the port-binding protocol even when it is implicitly tcp #427.
    @container_port << '/tcp' unless @container_port.include?('/')
  end
end
