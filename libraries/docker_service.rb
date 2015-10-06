require 'docker'
require 'helpers_service'

class Chef
  class Resource
    class DockerService < DockerBase
      use_automatic_resource_name

      # register with the resource resolution system
      provides :docker_service

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

      default_action :create

      declare_action_class.class_eval do
        include DockerHelpers
        include DockerHelpers::Service
      end

      # Put the appropriate bits on disk.
      action :create do
        # Pull a precompiled binary off the network
        remote_file docker_bin do
          source parsed_source
          checksum parsed_checksum
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
          @current_resource = Chef::Resource::DockerService.new(new_resource.name)

          Docker.url = parsed_connect_host if parsed_connect_host

          if parsed_connect_host =~ /^tcp:/ && new_resource.tls_ca_cert
            Docker.options = {
              ssl_ca_file: new_resource.tls_ca_cert,
              client_cert: new_resource.tls_client_cert,
              client_key: new_resource.tls_client_key,
              scheme: 'https'
            }
          end

          # require 'pry' ; binding.pry

          if docker_running?
            @current_resource.storage_driver Docker.info['Driver']
          else
            return @current_resource
          end
        end

        def resource_changes
          changes = []
          changes << :storage_driver if update_storage_driver?
          changes
        end
      end

      # Declare a module for subresoures' providers to sit in (backcompat)
      module Chef::Provider::DockerService; end
    end
  end
end
