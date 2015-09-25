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

IPV6_CIDR ||= /s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:)))(%.+)?s*/

IPV4_CIDR ||= %r{(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/([0-9]|[1-2][0-9]|3[0-2]))}

module DockerHelpers
  module Service
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

    def docker_name
      'docker'
    end

    def parsed_checksum
      return new_resource.checksum if new_resource.checksum
      case docker_kernel
      when 'Darwin'
        case parsed_version
        when '1.6.0' then '9e960e925561b4ec2b81f52b6151cd129739c1f4fba91ce94bdc0333d7d98c38'
        when '1.6.2' then 'f29b8b2185c291bd276f7cdac45a674f904e964426d5b969fda7b8ef6b8ab557'
        when '1.7.0' then '1c8ee59249fdde401afebc9a079cb75d7674f03d2491789fb45c88020a8c5783'
        when '1.7.1' then 'b8209b4382d0b4292c756dd055c12e5efacec2055d5900ac91efc8e81d317cf9'
        when '1.8.1' then '0f5db35127cf14b57614ad7513296be600ddaa79182d8d118d095cb90c721e3a'
        when '1.8.2' then 'cef593612752e5a50bd075931956075a534b293b7002892072397c3093fe11a6'
        end
      when 'Linux'
        case parsed_version
        when '1.6.0' then '526fbd15dc6bcf2f24f99959d998d080136e290bbb017624a5a3821b63916ae8'
        when '1.6.2' then 'e131b2d78d9f9e51b0e5ca8df632ac0a1d48bcba92036d0c839e371d6cf960ec'
        when '1.7.1' then '4d535a62882f2123fb9545a5d140a6a2ccc7bfc7a3c0ec5361d33e498e4876d5'
        when '1.8.1' then '843f90f5001e87d639df82441342e6d4c53886c65f72a5cc4765a7ba3ad4fc57'
        when '1.8.2' then '97a3f5924b0b831a310efa8bf0a4c91956cd6387c4a8667d27e2b2dd3da67e4d'
        end
      end
    end

    def parsed_pidfile
      return new_resource.pidfile if new_resource.pidfile
      "/var/run/#{docker_name}.pid"
    end

    def parsed_version
      return new_resource.version if new_resource.version
      return '1.6.2' if node['platform'] == 'amazon'
      return '1.6.2' if node['platform'] == 'ubuntu' && node['platform_version'].to_f < 15.04
      return '1.6.2' if node['platform_family'] == 'rhel' && node['platform_version'].to_i < 7
      return '1.6.2' if node['platform_family'] == 'debian' && node['platform_version'].to_i <= 7
      '1.8.2'
    end

    def docker_major_version
      ray = parsed_version.split('.')
      ray.pop
      ray.push.join('.')
    end

    # https://get.docker.com/builds/Linux/x86_64/docker-1.8.2
    # https://get.docker.com/builds/Darwin/x86_64/docker-1.8.2
    def parsed_source
      return new_resource.source if new_resource.source
      "https://get.docker.com/builds/#{docker_kernel}/#{docker_arch}/docker-#{parsed_version}"
    end

    def docker_daemon_arg
      if docker_major_version.to_f < 1.8
        '-d'
      else
        'daemon'
      end
    end

    def docker_daemon_cmd
      [docker_bin, docker_daemon_arg, docker_opts].join(' ')
    end

    def parsed_dns
      Array(new_resource.dns)
    end

    # strip out invalid host arguments
    def parsed_host
      sockets = new_resource.host.split if new_resource.host.is_a?(String)
      sockets = new_resource.host if new_resource.host.is_a?(Array)
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

    def parsed_log_opts
      Array(new_resource.log_opts)
    end

    def parsed_storage_driver
      Array(new_resource.storage_driver)
    end

    def parsed_storage_opts
      Array(new_resource.storage_opts)
    end

    def docker_opts
      opts = []
      opts << "--api-cors-header=#{new_resource.api_cors_header}" if new_resource.api_cors_header
      opts << "--bridge=#{new_resource.bridge}" if new_resource.bridge
      opts << "--bip=#{new_resource.bip}" if new_resource.bip
      opts << '--debug' if new_resource.debug
      opts << "--default-ulimit=#{new_resource.default_ulimit}" if new_resource.default_ulimit
      parsed_dns.each { |dns| opts << "--dns=#{dns}" }
      new_resource.dns_search.each { |dns| opts << "--dns-search=#{dns}" } if new_resource.dns_search
      opts << "--exec-driver=#{new_resource.exec_driver}" if new_resource.exec_driver
      opts << "--fixed-cidr=#{new_resource.fixed_cidr}" if new_resource.fixed_cidr
      opts << "--fixed-cidr-v6=#{new_resource.fixed_cidr_v6}" if new_resource.fixed_cidr_v6
      opts << "--group=#{new_resource.group}" if new_resource.group
      opts << "--graph=#{new_resource.graph}" if new_resource.graph
      parsed_host.each { |h| opts << "-H #{h}" } if new_resource.host
      opts << '--icc=true' if new_resource.icc
      opts << "--insecure-registry=#{new_resource.insecure_registry}" if new_resource.insecure_registry
      opts << "--ip=#{new_resource.ip}" if new_resource.ip
      opts << "--ip-forward=#{new_resource.ip_forward}" unless new_resource.ip_forward.nil?
      opts << '--ip-masq=true' if new_resource.ip_masq
      opts << '--iptables=true' if new_resource.iptables
      opts << '--ipv6=true' if new_resource.ipv6
      opts << "--log-level=#{new_resource.log_level}" if new_resource.log_level
      opts << "--label=#{new_resource.label}" if new_resource.label
      opts << "--log-driver=#{new_resource.log_driver}" if new_resource.log_driver
      parsed_log_opts.each { |log_opt| opts << "--log-opt=#{log_opt}" }
      opts << "--mtu=#{new_resource.mtu}" if new_resource.mtu
      opts << "--pidfile=#{new_resource.pidfile}" if new_resource.pidfile
      opts << "--registry-mirror=#{new_resource.registry_mirror}" if new_resource.registry_mirror
      parsed_storage_driver.each { |s| opts << "--storage-driver=#{s}" } if new_resource.storage_driver
      opts << '--selinux-enabled=true' if new_resource.selinux_enabled
      parsed_storage_opts.each { |storage_opt| opts << "--storage-opt=#{storage_opt}" }
      opts << '--tls=true' if new_resource.tls
      opts << "--tlscacert=#{new_resource.tlscacert}" if new_resource.tlscacert
      opts << "--tlscert=#{new_resource.tlscert}" if new_resource.tlscert
      opts << "--tlskey=#{new_resource.tlskey}" if new_resource.tlskey
      opts << '--tlsverify=true' if new_resource.tlsverify
      opts << "--userland-proxy=#{new_resource.userland_proxy}" unless new_resource.userland_proxy.nil?
      opts
    end

    # 423
    def docker_running?
      return true if ::File.exist?('/var/run/docker.sock')
    end

    def update_storage_driver?
      return false if new_resource.storage_driver.nil?
      return true if current_resource.storage_driver != new_resource.storage_driver
      false
    end
  end
end
