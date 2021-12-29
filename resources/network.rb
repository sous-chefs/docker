unified_mode true
use 'partial/_base'

require 'ipaddress'

property :auxiliary_addresses, [String, Array, nil], coerce: proc { |v| coerce_auxiliary_addresses(v) }
property :container, String, desired_state: false
property :driver, String
property :driver_opts, PartialHashType
property :enable_ipv6, [true, false]
property :gateway, [String, Array, nil], coerce: proc { |v| coerce_gateway(v) }
property :host, [String, nil], default: lazy { ENV['DOCKER_HOST'] }, desired_state: false
property :id, String
property :internal, [true, false]
property :ip_range, [String, Array, nil], coerce: proc { |v| coerce_ip_range(v) }
property :ipam_driver, String
property :network, Docker::Network, desired_state: false
property :network_name, String, name_property: true
property :subnet, [String, Array, nil], coerce: proc { |v| coerce_subnet(v) }
property :ip, String, callbacks: { 'invalid IPv4' => proc { |v| IPAddress(v).ipv4? } }
property :ip6, String, callbacks: { 'invalid IPv6' => proc { |v| IPAddress(v).ipv6? } }

alias_method :aux_address, :auxiliary_addresses

###################
# property helpers
###################

def coerce_auxiliary_addresses(v)
  ray = []
  Array(v).each do |e|
    case e
    when String, Array, nil
      ray += Array(e)
    when Hash
      e.each { |key, val| ray << "#{key}=#{val}" }
    end
  end
  ray.length == 1 ? ray[0] : ray
end

def coerce_gateway(v)
  case v
  when String
    v.split('/')[0]
  when Array
    ray = Array(v).map { |a| a.split('/')[0] }
    ray.length == 1 ? ray[0] : ray
  end
end

def coerce_subnet(v)
  Array(v).length == 1 ? Array(v)[0] : v
end

def coerce_ip_range(v)
  Array(v).length == 1 ? Array(v)[0] : v
end

####################
# load current value
####################

load_current_value do
  begin
    with_retries { network Docker::Network.get(network_name, {}, connection) }
  rescue Docker::Error::NotFoundError
    current_value_does_not_exist!
  end

  aux_addr_ray = []
  gateway_ray = []
  ip_range_ray = []
  subnet_ray = []

  network.info['IPAM']['Config'].to_a.each do |conf|
    conf.each do |key, value|
      case key
      when 'AuxiliaryAddresses'
        aux_addr_ray << value
      when 'Gateway'
        gateway_ray << value
      when 'IPRange'
        ip_range_ray << value
      when 'Subnet'
        subnet_ray << value
      end
    end
  end

  auxiliary_addresses aux_addr_ray
  gateway gateway_ray
  ip_range ip_range_ray
  subnet subnet_ray

  driver network.info['Driver']
  driver_opts network.info['Options']
  internal network.info['Internal']
  enable_ipv6 network.info['EnableIPv6']
end

action :create do
  converge_if_changed do
    action_delete

    with_retries do
      options = {}
      options['Driver'] = new_resource.driver if new_resource.driver
      options['Options'] = new_resource.driver_opts if new_resource.driver_opts
      ipam_options = consolidate_ipam(new_resource.subnet, new_resource.ip_range, new_resource.gateway, new_resource.aux_address)
      options['IPAM'] = { 'Config' => ipam_options } unless ipam_options.empty?
      options['IPAM']['Driver'] = new_resource.ipam_driver if new_resource.ipam_driver
      options['EnableIPv6'] = new_resource.enable_ipv6 if new_resource.enable_ipv6
      options['Internal'] = new_resource.internal if new_resource.internal
      Docker::Network.create(new_resource.network_name, options)
    end
  end
end

action :delete do
  return unless current_resource
  converge_by "deleting #{new_resource.network_name}" do
    with_retries do
      current_resource.network.delete
    end
  end
end

action :remove do
  action_delete
end

action :connect do
  unless new_resource.container
    raise Chef::Exceptions::ValidationFailed, 'Container id or name is required for action :connect'
  end

  if current_resource
    container_info = current_resource.network.info['Containers'].values.find { |c| c['Name'] == new_resource.container }

    unless container_info.nil?
      # check whether we must disconnect the container first to correct its IP
      must_disconnect = false

      if property_is_set?(:ip) && (container_info['IPv4Address'].empty? || IPAddress(container_info['IPv4Address']) != IPAddress(new_resource.ip))
        must_disconnect = true
      end

      if property_is_set?(:ip6) && (container_info['IPv6Address'].empty? || IPAddress(container_info['IPv6Address']) != IPAddress(new_resource.ip6))
        must_disconnect = true
      end

      if must_disconnect
        converge_by("disconnecting #{new_resource.container} to reattach it with the correct IP config") do
          with_retries do
            current_resource.network.disconnect(new_resource.container)
          end
        end
        container_info = nil
      end
    end

    if container_info.nil?
      converge_by("connect #{new_resource.container}") do
        body_opts = {}
        ((body_opts['EndpointConfig'] ||= {})['IPAMConfig'] ||= {})['IPv4Address'] = new_resource.ip if property_is_set?(:ip)
        ((body_opts['EndpointConfig'] ||= {})['IPAMConfig'] ||= {})['IPv6Address'] = new_resource.ip6 if property_is_set?(:ip6)

        with_retries do
          current_resource.network.connect(new_resource.container, {}, body_opts)
        end
      end
    end
  else
    raise "Cannot connect to #{new_resource.network_name}: network does not exist"
  end
end

action :disconnect do
  unless new_resource.container
    raise Chef::Exceptions::ValidationFailed, 'Container id or name is required for action :disconnect'
  end

  if current_resource
    container_index = current_resource.network.info['Containers'].values.index { |c| c['Name'] == new_resource.container }
    unless container_index.nil?
      converge_by("disconnect #{new_resource.container}") do
        with_retries do
          current_resource.network.disconnect(new_resource.container)
        end
      end
    end
  else
    Chef::Log.warn("Cannot disconnect from #{network_name}: network does not exist")
  end
end

action_class do
  require 'ipaddr'

  ######
  # IPAM
  ######

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
      raise 'every ip-range or gateway myust have a corresponding subnet'
    end

    data = {}

    # Check overlapping subnets
    subnets.each do |s|
      data.each do |k, _|
        if subnet_matches(s, k) || subnet_matches(k, s)
          raise 'multiple overlapping subnet configuration is not supported'
        end
      end
      data[s] = { 'Subnet' => s, 'AuxiliaryAddresses' => {} }
    end

    ranges.each do |r|
      match = false
      subnets.each do |s|
        ok = subnet_matches(s, r)
        next unless ok
        if data[s].fetch('IPRange', '') != ''
          raise 'cannot configure multiple ranges on the same subnet'
        end
        data[s]['IPRange'] = r
        match = true
      end
      raise "no matching subnet for range #{r}" unless match
    end

    gateways.each do |g|
      subnets.each do |s|
        ok = subnet_matches(s, g)
        next unless ok
        unless data[s].fetch('Gateway', '').empty?
          raise "cannot configure multiple gateways (#{g}, #{data[s]['Gateway']}) for the same subnet (#{s})"
        end
        data[s]['Gateway'] = g
      end
    end

    auxaddrs.each do |aa|
      key, a = aa.split('=')
      match = false
      subnets.each do |s|
        # require 'pry' ; binding.pry
        ok = subnet_matches(s, a)
        next unless ok
        data[s]['AuxiliaryAddresses'][key] = a
        match = true
      end
      raise "no matching subnet for aux-address #{a}" unless match
    end
    data.values
  end

  def subnet_matches(subnet, data)
    s = IPAddress(subnet)
    d = IPAddress(data)

    return false unless s.class.eql?(d.class)

    s.include?(d)
  end
end
