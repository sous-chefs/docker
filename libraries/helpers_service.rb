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
    def docker_bin
      '/usr/bin/docker'
    end

    def docker_major_version
      ray = version.split('.')
      ray.pop
      ray.push.join('.')
    end

    def docker_daemon_arg
      if docker_major_version.to_f < 1.8
        '-d'
      else
        'daemon'
      end
    end

    def docker_daemon_cmd
      [docker_bin, docker_daemon_arg, docker_daemon_opts].join(' ')
    end

    def docker_cmd
      [docker_bin, docker_opts].join(' ')
    end

    # Try to connect to docker socket twenty times
    def docker_wait_ready
      bash 'docker-wait-ready' do
        code <<-EOF
        timeout=0
        while [ $timeout -lt 20 ];  do
          ((timeout++))
          #{docker_cmd} ps | head -n 1 | grep ^CONTAINER
          if [ $? -eq 0 ]; then
            break
          fi
          sleep 1
        done
        [[ $timeout -eq 20 ]] && exit 1
        exit 0
        EOF
        not_if "#{docker_cmd} ps | head -n 1 | grep ^CONTAINER"
      end
    end

    def docker_opts
      opts = []
      opts << "--host=#{connect_host}" if connect_host
      if connect_host =~ /^tcp:/
        opts << "--tls=#{tls}" unless tls.nil?
        opts << "--tlsverify=#{tls_verify}" unless tls_verify.nil?
        opts << "--tlscacert=#{tls_ca_cert}" if tls_ca_cert
        opts << "--tlscert=#{tls_client_cert}" if tls_client_cert
        opts << "--tlskey=#{tls_client_key}" if tls_client_key
      end
      opts
    end

    def docker_daemon_opts
      opts = []
      opts << "--api-cors-header=#{api_cors_header}" if api_cors_header
      opts << "--bridge=#{bridge}" if bridge
      opts << "--bip=#{bip}" if bip
      opts << '--debug' if debug
      default_ulimit.each { |u| opts << "--default-ulimit=#{u}" } if default_ulimit
      dns.each { |dns| opts << "--dns=#{dns}" } if dns
      dns_search.each { |dns| opts << "--dns-search=#{dns}" } if dns_search
      opts << "--exec-driver=#{exec_driver}" if exec_driver
      opts << "--fixed-cidr=#{fixed_cidr}" if fixed_cidr
      opts << "--fixed-cidr-v6=#{fixed_cidr_v6}" if fixed_cidr_v6
      opts << "--group=#{group}" if group
      opts << "--graph=#{graph}" if graph
      host.each { |h| opts << "-H #{h}" } if host
      opts << "--icc=#{icc}" unless icc.nil?
      opts << "--insecure-registry=#{insecure_registry}" if insecure_registry
      opts << "--ip=#{ip}" if ip
      opts << "--ip-forward=#{ip_forward}" unless ip_forward.nil?
      opts << '--ip-masq=true' if ip_masq
      opts << '--iptables=true' if iptables
      opts << '--ipv6=true' if ipv6
      opts << "--log-level=#{log_level}" if log_level
      opts << "--label=#{label}" if label
      opts << "--log-driver=#{log_driver}" if log_driver
      log_opts.each { |log_opt| opts << "--log-opt=#{log_opt}" } if log_opts
      opts << "--mtu=#{mtu}" if mtu
      opts << "--pidfile=#{pidfile}" if pidfile
      opts << "--registry-mirror=#{registry_mirror}" if registry_mirror
      storage_driver.each { |s| opts << "--storage-driver=#{s}" } if storage_driver
      opts << '--selinux-enabled=true' if selinux_enabled
      storage_opts.each { |storage_opt| opts << "--storage-opt=#{storage_opt}" } if storage_opts
      opts << "--tls=#{tls}" unless tls.nil?
      opts << "--tlsverify=#{tls_verify}" unless tls_verify.nil?
      opts << "--tlscacert=#{tls_ca_cert}" if tls_ca_cert
      opts << "--tlscert=#{tls_server_cert}" if tls_server_cert
      opts << "--tlskey=#{tls_server_key}" if tls_server_key
      opts << "--userland-proxy=#{userland_proxy}" unless userland_proxy.nil?
      opts
    end

    def docker_running?
      o = shell_out("#{docker_cmd} ps | head -n 1 | grep ^CONTAINER")
      return true if o.stdout =~ /CONTAINER/
      false
    end

    def update_storage_driver?
      return false if storage_driver.nil?
      return true if current_resource.storage_driver != storage_driver
      false
    end
  end
end
