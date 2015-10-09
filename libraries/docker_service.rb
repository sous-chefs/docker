require 'docker'
require 'helpers_service'

class Chef
  class Resource
    class DockerService < DockerBase
      use_automatic_resource_name

      # register with the resource resolution system
      provides :docker_service

      # service installation
      property :source, String, default: (lazy do
        "https://get.docker.com/builds/#{docker_kernel}/#{docker_arch}/docker-#{version}"
      end)
      property :version, String, default: (lazy do
        if node['platform'] == 'amazon' ||
           node['platform'] == 'ubuntu' && node['platform_version'].to_f < 15.04 ||
           node['platform_family'] == 'rhel' && node['platform_version'].to_i < 7 ||
           node['platform_family'] == 'debian' && node['platform_version'].to_i <= 7
          '1.6.2'
        else
          '1.8.2'
        end
      end)
      property :checksum, String, default: (lazy do
        case docker_kernel
        when 'Darwin'
          case version
          when '1.6.0' then '9e960e925561b4ec2b81f52b6151cd129739c1f4fba91ce94bdc0333d7d98c38'
          when '1.6.2' then 'f29b8b2185c291bd276f7cdac45a674f904e964426d5b969fda7b8ef6b8ab557'
          when '1.7.0' then '1c8ee59249fdde401afebc9a079cb75d7674f03d2491789fb45c88020a8c5783'
          when '1.7.1' then 'b8209b4382d0b4292c756dd055c12e5efacec2055d5900ac91efc8e81d317cf9'
          when '1.8.1' then '0f5db35127cf14b57614ad7513296be600ddaa79182d8d118d095cb90c721e3a'
          when '1.8.2' then 'cef593612752e5a50bd075931956075a534b293b7002892072397c3093fe11a6'
          end
        when 'Linux'
          case version
          when '1.6.0' then '526fbd15dc6bcf2f24f99959d998d080136e290bbb017624a5a3821b63916ae8'
          when '1.6.2' then 'e131b2d78d9f9e51b0e5ca8df632ac0a1d48bcba92036d0c839e371d6cf960ec'
          when '1.7.1' then '4d535a62882f2123fb9545a5d140a6a2ccc7bfc7a3c0ec5361d33e498e4876d5'
          when '1.8.1' then '843f90f5001e87d639df82441342e6d4c53886c65f72a5cc4765a7ba3ad4fc57'
          when '1.8.2' then '97a3f5924b0b831a310efa8bf0a4c91956cd6387c4a8667d27e2b2dd3da67e4d'
          end
        end
      end)
      # daemon runtime arguments
      property :instance,        String, name_property: true, required: true
      property :api_cors_header, [String, nil]
      property :bridge,          [IPV4_ADDR, IPV6_ADDR, nil]
      property :bip,             [IPV4_ADDR, IPV4_CIDR, IPV6_ADDR, IPV6_CIDR, nil]
      property :debug,           [Boolean, nil]
      property :daemon,          Boolean, default: true
      property :dns,             ArrayType
      property :dns_search,      [Array, nil]
      property :exec_driver,     ['native', 'lxc', nil]
      property :fixed_cidr,      [String, nil]
      property :fixed_cidr_v6,   [String, nil]
      property :group,           [String, nil]
      property :graph,           [String, nil]
      property :host,            [String, Array], coerce: (proc do |v|
        v = v.split if v.is_a?(String)
        r = []
        Array(v).each do |s|
          if s.match(/^unix:/) || s.match(/^tcp:/) || s.match(/^fd:/)
            r << s
          else
            Chef::Log.info("WARNING: docker_service host property #{s} not valid")
          end
        end
        r
      end)
      property :icc,             [Boolean, nil]
      property :insecure_registry, [String, nil]
      property :ip,              [IPV4_ADDR, IPV6_ADDR, nil]
      property :ip_forward,      [Boolean, nil]
      property :ipv4_forward,    Boolean, default: true
      property :ipv6_forward,    Boolean, default: true
      property :ip_masq,         [Boolean, nil]
      property :iptables,        [Boolean, nil]
      property :ipv6,            [Boolean, nil]
      property :log_level,       [:debug, :info, :warn, :error, :fatal, nil]
      property :label,           [String, nil]
      property :log_driver,      ['json-file', 'syslog', 'journald', 'gelf', 'fluentd', 'none', nil]
      property :log_opts,        ArrayType
      property :mtu,             [String, nil]
      property :pidfile,         String, default: lazy { "/var/run/#{docker_name}.pid" }
      property :registry_mirror, [String, nil]
      property :storage_driver,  ArrayType
      property :selinux_enabled, [Boolean, nil]
      property :storage_opts,    ArrayType
      property :tls,             [Boolean, nil]
      property :tls_verify,      [Boolean, nil]
      property :tls_ca_cert,     [String, nil]
      property :tls_server_cert, [String, nil]
      property :tls_server_key,  [String, nil]
      property :tls_client_cert, [String, nil]
      property :tls_client_key,  [String, nil]
      property :default_ulimit,  ArrayType
      property :userland_proxy,  [Boolean, nil]

      # environment variables to set before running daemon
      property :http_proxy,      [String, nil]
      property :https_proxy,     [String, nil]
      property :no_proxy,        [String, nil]
      property :tmpdir,          [String, nil]

      # logging
      property :logfile,         String, default: '/var/log/docker.log'

      alias_method :tlscacert, :tls_ca_cert
      alias_method :tlscert, :tls_server_cert
      alias_method :tlskey, :tls_server_key
      alias_method :tlsverify, :tls_verify

      protected

      def docker_name
        'docker'
      end

      def docker_kernel
        node['kernel']['name']
      end

      def docker_arch
        node['kernel']['machine']
      end

      default_action :create

      declare_action_class.class_eval do
        include DockerHelpers
        include DockerHelpers::Service
      end

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
        def connect_host
          host.first if host
        end

        def load_current_resource
          @current_resource = Chef::Resource::DockerService.new(name)

          Docker.url = connect_host if connect_host

          if connect_host =~ /^tcp:/ && tls_ca_cert
            Docker.options = {
              ssl_ca_file: tls_ca_cert,
              client_cert: tls_client_cert,
              client_key: tls_client_key,
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
      class ::Chef
        class Provider
          module DockerService
          end
        end
      end
    end
  end
end
