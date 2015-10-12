require 'docker'
require 'helpers_service'

class Chef
  class Resource
    class DockerService < DockerBase
      use_automatic_resource_name

      include DockerHelpers::Service

      # register with the resource resolution system
      provides :docker_service

      # service installation
      property :source, String, default: lazy { default_source }
      property :version, String, default: lazy { default_version }
      property :checksum, String, default: lazy { default_checksum }
      property :instance, String, name_property: true, required: true
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
      property :label, [String, nil]
      property :log_driver, ['json-file', 'syslog', 'journald', 'gelf', 'fluentd', 'none', nil]
      property :log_opts, ArrayType
      property :mtu, [String, nil]
      property :pidfile, String, default: '/var/run/docker.pid'
      property :registry_mirror, [String, nil]
      property :storage_driver, ArrayType
      property :selinux_enabled, [Boolean, nil]
      property :storage_opts, ArrayType
      property :tls, [Boolean, nil]
      property :tls_verify, [Boolean, nil]
      property :tls_ca_cert, [String, nil]
      property :tls_server_cert, [String, nil]
      property :tls_server_key, [String, nil]
      property :tls_client_cert, [String, nil]
      property :tls_client_key, [String, nil]
      property :default_ulimit, ArrayType
      property :userland_proxy, [Boolean, nil]

      # environment variables to set before running daemon
      property :http_proxy, [String, nil]
      property :https_proxy, [String, nil]
      property :no_proxy, [String, nil]
      property :tmpdir, [String, nil]

      # logging
      property :logfile, String, default: '/var/log/docker.log'

      alias_method :tlscacert, :tls_ca_cert
      alias_method :tlscert, :tls_server_cert
      alias_method :tlskey, :tls_server_key
      alias_method :tlsverify, :tls_verify

      default_action :create

      #########
      # Actions
      #########

      # Put the appropriate bits on disk.
      action :create do
        # Pull a precompiled binary off the network
        remote_file docker_bin do
          source new_resource.source
          checksum new_resource.checksum
          owner 'root'
          group 'root'
          mode '0755'
          action :create
          notifies :restart, new_resource
        end
      end

      action :delete do
        file docker_bin do
          action :delete
        end
      end

      # These are implemented in subclasses.
      action :start do
      end

      action :stop do
      end

      action :restart do
      end

      action_class.class_eval do
        def load_current_resource
          @current_resource = Chef::Resource::DockerService.new(name)

          connect_opts = {}
          if connect_host =~ /^tcp:/
            connect_opts[:scheme] = 'https'
            connect_opts[:ssl_ca_file] = tls_ca_cert if tls_ca_cert
            connect_opts[:client_cert] = tls_client_cert if tls_client_cert
            connect_opts[:client_key] = tls_client_key if tls_client_key
          end
          connection = Docker::Connection.new(connect_host || Docker.url, connect_opts)

          if docker_running?
            @current_resource.storage_driver Docker.info(connection)['Driver']
          else
            return @current_resource
          end
        end

        def resource_changes
          changes = []
          changes << :storage_driver if update_storage_driver?
          changes
        end

        def update_storage_driver?
          return false if storage_driver.nil?
          return true if current_resource.storage_driver != storage_driver
          false
        end
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
