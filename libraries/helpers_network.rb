module DockerCookbook
  module DockerHelpers
    module Network
      require 'ipaddr'
      def consolidate_ipam(subnets, ranges, gateways, auxaddrs)
        subnets = Array(subnets)
        ranges = Array(ranges)
        gateways = Array(gateways)
        auxaddrs = Array(auxaddrs)
        subnets = [] if subnets.empty?
        ranges = [] if ranges.empty?
        gateways = [] if gateways.empty?
        auxaddrs = [] if auxaddrs.empty?
        if subnets.size < ranges.size || subnets.size < gateways.size
          fail 'every ip-range or gateway myust have a corresponding subnet'
        end

        data = {}

        # Check overlapping subnets
        subnets.each do |s|
          data.each do |k, _|
            if subnet_matches(s, k) || subnet_matches(k, s)
              fail 'multiple overlapping subnet configuration is not supported'
            end
          end
          data[s] = { 'Subnet' => s, 'AuxAddress' => {} }
        end

        ranges.each do |r|
          match = false
          subnets.each do |s|
            ok = subnet_matches(s, r)
            next unless ok
            if data[s]['IPRange'] != ''
              fail 'cannot configure multiple ranges on the same subnet'
            end
            data[s]['IPRange']
            match = true
          end

          fail "no matching subnet for range #{r}" unless match
        end

        gateways.each do |g|
          match = false
          subnets.each do |s|
            ok = subnet_matches(s, g)
            next unless ok
            unless data[s].fetch('Gateway', '').empty?
              fail "cannot configure multiple gateways (#{g}, #{data[s]['Gateway']}) for the same subnet (#{s})"
            end
            data[s]['Gateway'] = g
            match = true
          end
          fail "no matching subnet for gateway #{s}" unless match
        end

        auxaddrs.each do |aa|
          key, a = aa.split('=')
          match = false
          subnets.each do |s|
            ok = subnet_matches(s, a)
            next unless ok
            data[s]['AuxAddress'][key] = a
            match = true
          end
          fail "no matching subnet for aux-address #{a}" unless match
        end

        data.values
      end

      def subnet_matches(subnet, data)
        IPAddr.new(subnet).include?(IPAddr.new(data))
      end
    end
  end
end
