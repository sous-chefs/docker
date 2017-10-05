module DockerCookbook
  module DockerHelpers
    module Container
      def coerce_links(v)
        case v
        when DockerBase::UnorderedArray, nil
          v
        else
          return nil if v.empty?
          # Parse docker input of /source:/container_name/dest into source:dest
          DockerBase::UnorderedArray.new(Array(v)).map! do |link|
            if link =~ %r{^/(?<source>.+):/#{name}/(?<dest>.+)}
              link = "#{Regexp.last_match[:source]}:#{Regexp.last_match[:dest]}"
            end
            link
          end
        end
      end

      def to_bytes(v)
        n = v.to_i
        u = v.gsub(/\d/, '').upcase

        multiplier = case u
                     when 'B'
                       1
                     when 'K'
                       1024**1
                     when 'M'
                       1024**2
                     when 'G'
                       1024**3
                     when 'T'
                       1024**4
                     when 'P'
                       1024**5
                     when 'E'
                       1024**6
                     when 'Z'
                       1024**7
                     when 'Y'
                       1024**8
                     else
                       1
                     end

        n * multiplier
      end

      def coerce_kernel_memory(v)
        case v
        when Integer, nil
          v
        else
          to_bytes(v)
        end
      end

      def coerce_memory(v)
        case v
        when Integer, nil
          v
        else
          to_bytes(v)
        end
      end

      def coerce_memory_swap(v)
        case v
        when Integer, nil
          v
        else
          to_bytes(v)
        end
      end

      def coerce_memory_swappiness(v)
        v.to_i
      end

      def coerce_memory_reservation(v)
        case v
        when Integer, nil
          v
        else
          to_bytes(v)
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
        return v if v.nil?
        Array(v).map do |u|
          u = "#{u['Name']}=#{u['Soft']}:#{u['Hard']}" if u.is_a?(Hash)
          u
        end
      end

      def coerce_volumes(v)
        case v
        when DockerBase::PartialHash, nil
          v
        when Hash
          DockerBase::PartialHash[v]
        else
          b = []
          v = Array(v).to_a # in case v.is_A?(Chef::Node::ImmutableArray)
          v.delete_if do |x|
            parts = x.split(':')
            b << x if parts.length > 1
          end
          b = nil if b.empty?
          volumes_binds b
          return DockerBase::PartialHash.new if v.empty?
          v.each_with_object(DockerBase::PartialHash.new) { |volume, h| h[volume] = {} }
        end
      end

      def state
        # Always return the latest state, see #510
        return Docker::Container.get(container_name, {}, connection).info['State']
      rescue
        return {}
      end

      def wait_running_state(v)
        tries = running_wait_time
        tries.times do
          return if state['Running'] == v
          sleep 1
        end
        return if state['Running'] == v

        # Container failed to reach correct state: Throw an error
        desired_state_str = v ? 'running' : 'not running'
        raise Docker::Error::TimeoutError, "Container #{container_name} failed to change to #{desired_state_str} state after #{tries} seconds"
      end

      def port(v = nil)
        return @port if v.nil?
        exposed_ports coerce_exposed_ports(v)
        port_bindings coerce_port_bindings(v)
        @port = v
        @port
      end

      def parse_port(v)
        _, protocol = v.split('/')
        parts = v.split(':')
        case parts.length
        when 3
          host_ip = parts[0]
          host_port = parts[1].split('-')
          container_port = parts[2].split('-')
        when 2
          host_ip = '0.0.0.0'
          host_port = parts[0].split('-')
          container_port = parts[1].split('-')
        when 1
          host_ip = ''
          host_port = ['']
          container_port = parts[0].split('-')
        end
        host_port.map!(&:to_i) unless host_port == ['']
        container_port.map!(&:to_i)
        if host_port.count > 1
          Chef::Log.fatal("FATAL: Invalid port range! #{host_port}") if host_port[0] > host_port[1]
          host_port = (host_port[0]..host_port[1]).to_a
        end
        if container_port.count > 1
          Chef::Log.fatal("FATAL: Invalid port range! #{container_port}") if container_port[0] > container_port[1]
          container_port = (container_port[0]..container_port[1]).to_a
        end
        Chef::Log.fatal('FATAL: Port range size does not match!') if host_port.count > 1 && host_port.count != container_port.count
        # qualify the port-binding protocol even when it is implicitly tcp #427.
        protocol = 'tcp' if protocol.nil?
        Array(container_port).map.with_index do |_, i|
          {
            'host_ip' => host_ip,
            'host_port' => host_port[i].to_s,
            'container_port' => "#{container_port[i]}/#{protocol}",
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
              'HostPort' => y['host_port'],
            }
          end
        end
      end

      def coerce_env_file(v)
        return v if v.empty?
        Array(v).map { |f| ::File.readlines(f).map(&:strip) }.flatten
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

      # TODO: test image property in serverspec and kitchen, not only in rspec
      # for full specs of image parsing, see spec/helpers_container_spec.rb
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
      # If you say:    `image 'repo/blah'`
      # Repo will be:  `repo/blah`
      # Tag will be:   `latest`
      #
      # If you say:    `image 'repo/blah:3.1'`
      # Repo will be:  `repo/blah`
      # Tag will be:   `3.1`
      #
      # If you say:    `image 'repo:1337/blah'`
      # Repo will be:  `repo:1337/blah`
      # Tag will be:   `latest'
      #
      # If you say:    `image 'repo:1337/blah:3.1'`
      # Repo will be:  `repo:1337/blah`
      # Tag will be:   `3.1`
      #
      def image(image = nil)
        if image
          if image.include?('/')
            # pathological case, a ':' may be present which starts the 'port'
            # part of the image name and not a tag. example: 'host:1337/blah'
            # fortunately, tags are only found in the 'basename' part of image
            # so we can split on '/' and rebuild once the tag has been parsed.
            dirname, _, basename = image.rpartition('/')
            r, t = basename.split(':', 2)
            r = [dirname, r].join('/')
          else
            # normal case, the ':' starts the tag part
            r, t = image.split(':', 2)
          end
          repo r
          tag t if t
        end
        "#{repo}:#{tag}"
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
