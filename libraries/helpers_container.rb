module DockerCookbook
  module DockerHelpers
    module Container
      def coerce_links(v)
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
      end

      def coerce_log_opts(v)
        case v
        when Hash, nil
          v
        else
          Array(v).each_with_object({}) do |log_opt, memo|
            key, value = log_opt.split('=', 2)
            memo[key] = value
          end
        end
      end

      def coerce_ulimits(v)
        if v.nil?
          v
        else
          Array(v).map do |u|
            u = "#{u['Name']}=#{u['Soft']}:#{u['Hard']}" if u.is_a?(Hash)
            u
          end
        end
      end

      def coerce_volumes(v)
        case v
        when nil, DockerBase::PartialHash
          v
        when Hash
          DockerBase::PartialHash[v]
        else
          Array(v).each_with_object(DockerBase::PartialHash.new) { |volume, h| h[volume] = {} }
        end
      end

      def default_network_mode
        case api_version
        when '1.19'
          'bridge'
        when proc { |n| n.to_f < 1.19 }
          ''
        else
          'default'
        end
      end

      def state
        container ? container.info['State'] : {}
      end

      def wait_running_state(v)
        i = 0
        tries = 20
        until state['Running'] == v || state['FinishedAt'] != '0001-01-01T00:00:00Z'
          i += 1
          break if i == tries
          sleep 1
        end
      end

      def port(v = nil)
        return @port if v.nil?
        exposed_ports coerce_exposed_ports(v)
        port_bindings coerce_port_bindings(v)
        @port = v
        @port
      end

      def parse_port(v)
        parts = v.split(':')
        case parts.length
        when 3
          host_ip = parts[0]
          host_port = parts[1]
          container_port = parts[2]
        when 2
          host_ip = '0.0.0.0'
          host_port = parts[0]
          container_port = parts[1]
        when 1
          host_ip = ''
          host_port = ''
          container_port = parts[0]
        end
        port_range, protocol = container_port.split('/')
        if port_range.include?('-')
          port_range = container_port.split('-')
          port_range.map!(&:to_i)
          Chef::Log.fatal("FATAL: Invalid port range! #{container_port}") if port_range[0] > port_range[1]
          port_range = (port_range[0]..port_range[1]).to_a
        end
        # qualify the port-binding protocol even when it is implicitly tcp #427.
        protocol = 'tcp' if protocol.nil?
        Array(port_range).map do |port|
          {
            'host_ip' => host_ip,
            'host_port' => host_port,
            'container_port' => "#{port}/#{protocol}"
          }
        end
      end

      def coerce_exposed_ports(v)
        case v
        when Hash, nil
          v
        else
          x = Array(v).map { |a| parse_port(a) }
          x.flatten!
          x.each_with_object({}) do |y, h|
            h[y['container_port']] = {}
          end
        end
      end

      def coerce_port_bindings(v)
        case v
        when Hash, nil
          v
        else
          x = Array(v).map { |a| parse_port(a) }
          x.flatten!
          x.each_with_object({}) do |y, h|
            h[y['container_port']] = [] unless h[y['container_port']]
            h[y['container_port']] << {
              'HostIp' => y['host_ip'],
              'HostPort' => y['host_port']
            }
          end
        end
      end

      # log_driver and log_opts really handle this
      def log_config(value = Chef::NOT_PASSED)
        if value != Chef::NOT_PASSED
          @log_config = value
          log_driver value['Type']
          log_opts value['Config']
        end
        return @log_config if defined?(@log_config)
        def_logcfg = {}
        def_logcfg['Type'] = log_driver if property_is_set?(:log_driver)
        def_logcfg['Config'] = log_opts if property_is_set?(:log_opts)
        def_logcfg = nil if def_logcfg.empty?
        def_logcfg
      end

      # TODO: test image property in serverspec and kitchen
      # TODO: test this logic with rspec
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
      def image(image = nil)
        if image
          r, t = image.split(':', 2)
          repo r
          tag t if t
        end
        "#{repo}:#{tag}"
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
