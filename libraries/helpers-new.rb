# Constants
IPV6_ADDR = /(
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

IPV4_ADDR = /((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])/

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
      when '1.0.1' then 'b662e7718f0a8e23d2e819470a368f257e2bc46f76417712360de7def775e9d4'
      end
    when 'Linux'
      case parsed_version
      when '1.0.1' then '1d9aea20ec8e640ec9feb6757819ce01ca4d007f208979e3156ed687b809a75b'
      when '1.6.0' then '526fbd15dc6bcf2f24f99959d998d080136e290bbb017624a5a3821b63916ae8'
      end
    end
  end

  def parsed_pidfile
    return new_resource.pidfile if new_resource.pidfile
    "/var/run/#{docker_name}.pid"
  end

  def parsed_version
    return new_resource.version if new_resource.version
    '1.6.0'
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
    opts << " --host=#{new_resource.host}" if new_resource.host
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
    opts << " --storage_driver=#{new_resource.storage_driver}" if new_resource.storage_driver
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
