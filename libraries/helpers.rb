# Constants
IPV6_ADDR ||= /(
([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|
([0-9a-fA-F]{1,4}:){1,7}:|
([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|
([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|
([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|
([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|
([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|
[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|
:((:[0-9a-fA-F]{1,4}){1,7}|:)|
fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|
::(ffff(:0{1,4}){0,1}:){0,1}
((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}
(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|
([0-9a-fA-F]{1,4}:){1,4}:
((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}
(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])
)/

IPV4_ADDR ||= /((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])/

module DockerHelpers
  # Path to docker executable
  def docker_arch
    node['kernel']['machine']
  end

  def docker_bin
    '/usr/bin/docker'
  end

  def docker_kernel
    node['kernel']['name']
  end

  def docker_log
    '/var/log/docker.log'
  end

  def docker_name
    'docker'
  end

  def parsed_checksum
    case docker_arch
    when 'Darwin'
      case parsed_version
      when '1.6.0' then '9e960e925561b4ec2b81f52b6151cd129739c1f4fba91ce94bdc0333d7d98c38'
      when '1.6.2' then 'f29b8b2185c291bd276f7cdac45a674f904e964426d5b969fda7b8ef6b8ab557'
      when '1.7.0' then '1c8ee59249fdde401afebc9a079cb75d7674f03d2491789fb45c88020a8c5783'
      end
    when 'Linux'
      case parsed_version
      when '1.6.0' then '526fbd15dc6bcf2f24f99959d998d080136e290bbb017624a5a3821b63916ae8'
      when '1.6.2' then 'e131b2d78d9f9e51b0e5ca8df632ac0a1d48bcba92036d0c839e371d6cf960ec'
      when '1.7.0' then 'a27669f3409f5889cb86e6d9e7914d831788a9d96c12ecabb24472a6cd7b1007'
      end
    end
  end

  def parsed_pidfile
    return new_resource.pidfile if new_resource.pidfile
    "/var/run/#{docker_name}.pid"
  end

  def parsed_version
    return new_resource.version if new_resource.version
    '1.6.2'
  end

  def parsed_source
    return new_resource.source if new_resource.source
    "http://get.docker.io/builds/#{docker_kernel}/#{docker_arch}/docker-#{parsed_version}"
  end

  def docker_daemon_cmd
    cmd = "#{docker_bin} -d"
    docker_opts.each { |opt| cmd << opt }
    cmd
  end

  # strip out invalid host arguments
  def parsed_host
    sockets = new_resource.host.split if new_resource.host.class == String
    sockets = new_resource.host if new_resource.host.class == Array
    r = []
    sockets.each do |s|
      if s.match(/^unix:/) || s.match(/^tcp:/) || s.match(/^fd:/)
        r << s
      else
        Chef::Log.info("WARNING: docker_service host property #{s} not valid")
      end
    end
    r
  end

  def docker_opts
    opts = []
    opts << " --api-cors-header=#{new_resource.api_cors_header}" if new_resource.api_cors_header
    opts << " --bridge=#{new_resource.bridge}" if new_resource.bridge
    opts << " --bip=#{new_resource.bip}" if new_resource.bip
    opts << ' --debug' if new_resource.debug
    opts << " --default-ulimit=#{new_resource.default_ulimit}" if new_resource.default_ulimit
    opts << " --dns=#{new_resource.dns}" if new_resource.dns
    opts << " --dns-search=#{new_resource.dns_search}" if new_resource.dns_search
    opts << " --exec-driver=#{new_resource.exec_driver}" if new_resource.exec_driver
    opts << " --fixed-cidr=#{new_resource.fixed_cidr}" if new_resource.fixed_cidr
    opts << " --fixed-cidr-v6=#{new_resource.fixed_cidr_v6}" if new_resource.fixed_cidr_v6
    opts << " --group=#{new_resource.group}" if new_resource.group
    opts << " --graph=#{new_resource.graph}" if new_resource.graph
    parsed_host.each { |h| opts << " -H #{h}" } if new_resource.host
    opts << ' --icc=true' if new_resource.icc
    opts << " --insecure-registry=#{new_resource.insecure_registry}" if new_resource.insecure_registry
    opts << " --ip=#{new_resource.ip}" if new_resource.ip
    opts << ' --ip-forward=true' if new_resource.ip_forward
    opts << ' --ip-masq=true' if new_resource.ip_masq
    opts << ' --iptables=true' if new_resource.iptables
    opts << ' --ipv6=true' if new_resource.ipv6
    opts << " --log-level=#{new_resource.log_level}" if new_resource.log_level
    opts << " --label=#{new_resource.label}" if new_resource.label
    opts << " --log-driver=#{new_resource.log_driver}" if new_resource.log_driver
    opts << " --mtu=#{new_resource.mtu}" if new_resource.mtu
    opts << " --pidfile=#{new_resource.pidfile}" if new_resource.pidfile
    opts << " --registry-mirror=#{new_resource.registry_mirror}" if new_resource.registry_mirror
    opts << " --storage-driver=#{new_resource.storage_driver}" if new_resource.storage_driver
    opts << ' --selinux-enabled=true' if new_resource.selinux_enabled
    opts << " --storage-opt=#{new_resource.storage_opt}" if new_resource.storage_opt
    opts << ' --tls=true' if new_resource.tls
    opts << " --tlscacert=#{new_resource.tlscacert}" if new_resource.tlscacert
    opts << " --tlscert=#{new_resource.tlscert}" if new_resource.tlscert
    opts << " --tlskey=#{new_resource.tlskey}" if new_resource.tlskey
    opts << ' --tlsverify=true' if new_resource.tlsverify
    opts
  end
end
