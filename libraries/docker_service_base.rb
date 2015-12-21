module DockerCookbook
  class DockerServiceBase < DockerBase
    ################
    # Helper Methods
    ################
    require 'docker'
    require 'helpers_service'
    include DockerHelpers::Service

    #####################
    # resource properties
    #####################

    use_automatic_resource_name

    # register with the resource resolution system
    provides :docker_service_manager

    # daemon management
    property :instance, String, name_property: true, required: true, desired_state: false
    property :auto_restart, Boolean, default: false
    property :api_cors_header, [String, nil]
    property :bridge, [String, nil]
    property :bip, [IPV4_ADDR, IPV4_CIDR, IPV6_ADDR, IPV6_CIDR, nil]
    property :cluster_store, [String, nil]
    property :cluster_advertise, [String, nil]
    property :cluster_store_opts, ArrayType
    property :debug, [Boolean, nil]
    property :daemon, Boolean, default: true
    property :dns, ArrayType
    property :dns_search, [Array, nil]
    property :exec_driver, ['native', 'lxc', nil]
    property :exec_opts, ArrayType
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
    property :labels, [String, Array], coerce: proc { |v| coerce_daemon_labels(v) }, desired_state: false
    property :log_driver, ['json-file', 'syslog', 'journald', 'gelf', 'fluentd', 'none', nil]
    property :log_opts, ArrayType
    property :mtu, [String, nil]
    property :pidfile, String, default: lazy { "/var/run/#{docker_name}.pid" }
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
  end
end

# Declare a module for subresoures' providers to sit in (backcompat)
class Chef
  class Provider
    module DockerServiceBase
    end
  end
end
