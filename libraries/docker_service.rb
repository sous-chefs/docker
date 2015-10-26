module DockerCookbook
  class DockerService < DockerBase
    require 'docker'
    require 'helpers_service'
    include DockerHelpers::Service

    use_automatic_resource_name

    # register with the resource resolution system
    provides :docker_service

    # installation type
    property :install_method, %w(binary script package none auto), default: 'binary', desired_state: false

    # docker_installation_binary, passed through
    property :source, [String, nil], desired_state: false
    property :checksum, [String, nil], desired_state: false
    property :docker_bin, String, default: '/usr/bin/docker', desired_state: false
    property :version, String, default: lazy { docker_version }, desired_state: false

    # docker_installation_script, through
    property :repo, [String, nil]
    property :script_url, [String, nil]

    # daemon management
    property :instance, String, name_property: true, required: true, desired_state: false
    property :api_cors_header, [String, nil]
    property :bridge, [IPV4_ADDR, IPV6_ADDR, nil]
    property :bip, [IPV4_ADDR, IPV4_CIDR, IPV6_ADDR, IPV6_CIDR, nil]
    property :debug, [Boolean, nil]
    property :daemon, Boolean, default: true
    property :dns, ArrayType
    property :dns_search, [Array, nil]
    property :exec_driver, ['native', 'lxc', nil]
    property :fixed_cidr, [String, nil]
    property :fixed_cidr_v6, [String, nil]
    property :group, [String, nil]
    property :graph, [String, nil]
    property :host, [String, Array], coerce: proc { |v| coerce_host(v) }
    property :icc, [Boolean, nil]
    property :insecure_registry, [String, nil]
    property :ip, [IPV4_ADDR, IPV6_ADDR, nil]
    property :ip_forward, [Boolean, nil]
    property :ipv4_forward, Boolean, default: true
    property :ipv6_forward, Boolean, default: true
    property :ip_masq, [Boolean, nil]
    property :iptables, [Boolean, nil]
    property :ipv6, [Boolean, nil]
    property :log_level, [:debug, :info, :warn, :error, :fatal, nil]
    property :labels, [String, Array], coerce: proc { |v| coerce_daemon_labels(v) }
    property :log_driver, ['json-file', 'syslog', 'journald', 'gelf', 'fluentd', 'none', nil]
    property :log_opts, ArrayType
    property :mtu, [String, nil]
    property :pidfile, String, default: '/var/run/docker.pid'
    property :registry_mirror, [String, nil]
    property :storage_driver, ArrayType
    property :selinux_enabled, [Boolean, nil]
    property :storage_opts, ArrayType
    property :tls, [Boolean, nil]
    property :default_ulimit, ArrayType
    property :userland_proxy, [Boolean, nil]

    # environment variables to set before running daemon
    property :http_proxy, [String, nil]
    property :https_proxy, [String, nil]
    property :no_proxy, [String, nil]
    property :tmpdir, [String, nil]

    # logging
    property :logfile, String, default: '/var/log/docker.log'

    alias_method :label, :labels
    alias_method :tlscacert, :tls_ca_cert
    alias_method :tlscert, :tls_server_cert
    alias_method :tlskey, :tls_server_key
    alias_method :tlsverify, :tls_verify

    default_action :create

    #########
    # Actions
    #########

    action :create do
      property_def = proc do
        # used by binary install
        source new_resource.source if new_resource.source
        checksum new_resource.checksum if new_resource.checksum
        version new_resource.version if new_resource.version
        # used by script install
        repo new_resource.repo if new_resource.repo
        script_url new_resource.script_url if new_resource.script_url
        action :create
        notifies :restart, new_resource
      end

      case install_method
      when 'auto'
        docker_installation(new_resource.instance, &property_def)
      when 'binary'
        docker_installation_binary(new_resource.instance, &property_def)
      when 'script'
        docker_installation_script(new_resource.instance, &property_def)
      when 'package'
        docker_installation_package(new_resource.instance, &property_def)
      when 'none'
        Chef::Log.info('Skipping Docker installation. Assuming it was handled previously.')
      end
    end

    action :delete do
      docker_installation 'default' do
        action :delete
      end
    end
  end
end

# Declare a module for subresoures' providers to sit in (backcompat)
class Chef
  class Provider
    module DockerService
    end
  end
end
