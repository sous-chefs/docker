class Chef
  class Resource
    class DockerService < Chef::Resource::LWRPBase
      # Manually set the resource name because we're creating the classes
      # manually instead of letting the resource/ and providers/
      # directories auto-name things.
      self.resource_name = :docker_service

      # service actions
      actions :create, :delete, :start, :stop, :restart
      default_action :create

      # register with the resource resolution system
      if Chef::Provider.respond_to?(:provides)
        provides :docker_service
      end

      # service installation
      attribute :source, kind_of: String, default: nil
      attribute :version, kind_of: String, default: nil
      attribute :checksum, kind_of: String, default: nil

      # daemon runtime arguments
      attribute :instance, kind_of: String, name_attribute: true, required: true
      attribute :api_cors_header, kind_of: String, default: nil
      attribute :bridge, kind_of: String, regex: [IPV4_ADDR, IPV6_ADDR], default: nil
      attribute :bip, kind_of: String, regex: IPV4_ADDR,  default: nil
      attribute :debug, kind_of: [TrueClass, FalseClass], default: nil
      attribute :daemon, kind_of: [TrueClass, FalseClass], default: true
      attribute :dns, kind_of: String, default: nil
      attribute :dns_search, kind_of: Array, default: nil
      attribute :exec_driver, equal_to: %w(native lxc), default: nil
      attribute :fixed_cidr, kind_of: String, default: nil
      attribute :fixed_cidr_v6, kind_of: String, default: nil
      attribute :group, kind_of: String, default: nil
      attribute :graph, kind_of: String, default: nil
      attribute :host, kind_of: Array, default: nil
      attribute :icc, kind_of: [TrueClass, FalseClass], default: nil
      attribute :insecure_registry, kind_of: String, default: nil
      attribute :ip, kind_of: String, regex: [IPV4_ADDR, IPV6_ADDR], default: nil
      attribute :ip_forward, kind_of: [TrueClass, FalseClass], default: true
      attribute :ipv4_forward, kind_of: [TrueClass, FalseClass], default: true
      attribute :ipv6_forward, kind_of: [TrueClass, FalseClass], default: true
      attribute :ip_masq, kind_of: [TrueClass, FalseClass], default: nil
      attribute :iptables, kind_of: [TrueClass, FalseClass], default: nil
      attribute :ipv6, kind_of: [TrueClass, FalseClass], default: nil
      attribute :log_level, equal_to: [:debug, :info, :warn, :error, :fatal], default: :info
      attribute :label, kind_of: String, default: nil
      attribute :log_driver, equal_to: %w( json-file syslog none ), default: nil
      attribute :mtu, kind_of: String, default: nil
      attribute :pidfile, kind_of: String, default: nil
      attribute :registry_mirror, kind_of: String, default: nil
      attribute :storage_driver, kind_of: String, default: nil
      attribute :selinux_enabled, kind_of: [TrueClass, FalseClass], default: nil
      attribute :storage_opt, kind_of: String, default: nil
      attribute :tls, kind_of: [TrueClass, FalseClass], default: true
      attribute :tlscacert, kind_of: String, default: nil
      attribute :tlscert, kind_of: String, default: nil
      attribute :tlskey, kind_of: String, default: nil
      attribute :tlsverify, kind_of: [TrueClass, FalseClass], default: nil
      attribute :default_ulimit, kind_of: String, default: nil

      # environment variables to set before running daemon
      attribute :http_proxy, kind_of: String, default: nil
      attribute :https_proxy, kind_of: String, default: nil
      attribute :no_proxy, kind_of: String, default: nil
      attribute :tmpdir, kind_of: String, default: nil

      # logging
      attribute :logfile, kind_of: String, default: '/var/log/docker.log'

      include DockerHelpers
    end
  end
end
