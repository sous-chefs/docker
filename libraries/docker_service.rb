require_relative 'helpers_service'

class Chef
  class Resource
    class DockerService < ChefCompat::Resource
      use_automatic_resource_name

      # service actions
      allowed_actions :create, :delete, :start, :stop, :restart
      default_action :create

      # register with the resource resolution system
      provides :docker_service if Chef::Provider.respond_to?(:provides)

      # service installation
      property :source, kind_of: String, default: nil
      property :version, kind_of: String, default: nil
      property :checksum, kind_of: String, default: nil

      # daemon runtime arguments
      property :instance, kind_of: String, name_attribute: true, required: true
      property :api_cors_header, kind_of: String, default: nil
      property :bridge, kind_of: String, regex: [IPV4_ADDR, IPV6_ADDR], default: nil
      property :bip, kind_of: String, regex: [IPV4_ADDR, IPV4_CIDR, IPV6_ADDR, IPV6_CIDR], default: nil
      property :debug, kind_of: [TrueClass, FalseClass], default: nil
      property :daemon, kind_of: [TrueClass, FalseClass], default: true
      property :dns, kind_of: [String, Array], default: []
      property :dns_search, kind_of: Array, default: nil
      property :exec_driver, equal_to: %w(native lxc), default: nil
      property :fixed_cidr, kind_of: String, default: nil
      property :fixed_cidr_v6, kind_of: String, default: nil
      property :group, kind_of: String, default: nil
      property :graph, kind_of: String, default: nil
      property :host, kind_of: [String, Array], default: nil
      property :icc, kind_of: [TrueClass, FalseClass], default: nil
      property :insecure_registry, kind_of: String, default: nil
      property :ip, kind_of: String, regex: [IPV4_ADDR, IPV6_ADDR], default: nil
      property :ip_forward, kind_of: [TrueClass, FalseClass], default: nil
      property :ipv4_forward, kind_of: [TrueClass, FalseClass], default: true
      property :ipv6_forward, kind_of: [TrueClass, FalseClass], default: true
      property :ip_masq, kind_of: [TrueClass, FalseClass], default: nil
      property :iptables, kind_of: [TrueClass, FalseClass], default: nil
      property :ipv6, kind_of: [TrueClass, FalseClass], default: nil
      property :log_level, equal_to: [:debug, :info, :warn, :error, :fatal], default: nil
      property :label, kind_of: String, default: nil
      property :log_driver, equal_to: %w( json-file syslog journald gelf fluentd none ), default: nil
      property :log_opts, kind_of: [String, Array], default: []
      property :mtu, kind_of: String, default: nil
      property :pidfile, kind_of: String, default: nil
      property :registry_mirror, kind_of: String, default: nil
      property :storage_driver, kind_of: [String, Array], default: nil
      property :selinux_enabled, kind_of: [TrueClass, FalseClass], default: nil
      property :storage_opts, kind_of: [String, Array], default: []
      property :tls, kind_of: [TrueClass, FalseClass], default: nil
      property :tls_verify, kind_of: [TrueClass, FalseClass], default: nil
      property :tls_ca_cert, kind_of: String, default: nil
      property :tls_server_cert, kind_of: String, default: nil
      property :tls_server_key, kind_of: String, default: nil
      property :tls_client_cert, kind_of: String, default: nil
      property :tls_client_key, kind_of: String, default: nil
      property :default_ulimit, kind_of: [String, Array], default: nil
      property :userland_proxy, kind_of: [TrueClass, FalseClass], default: nil

      # environment variables to set before running daemon
      property :http_proxy, kind_of: String, default: nil
      property :https_proxy, kind_of: String, default: nil
      property :no_proxy, kind_of: String, default: nil
      property :tmpdir, kind_of: String, default: nil

      # logging
      property :logfile, kind_of: String, default: '/var/log/docker.log'

      alias_method :tlscacert, :tls_ca_cert
      alias_method :tlscert, :tls_server_cert
      alias_method :tlskey, :tls_server_key
      alias_method :tlsverify, :tls_verify

      include DockerHelpers
    end
  end
end
