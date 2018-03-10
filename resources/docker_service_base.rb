################
# Helper Methods
################
require 'docker'
require_relative 'helpers_service'
include DockerHelpers::Service

# Environment variables to docker service
property :env_vars, Hash

# daemon management
property :instance, String, name_property: true, desired_state: false
property :auto_restart, [true, false], default: false
property :api_cors_header, [String, nil]
property :bridge, [String, nil]
property :bip, [IPV4_ADDR, IPV4_CIDR, IPV6_ADDR, IPV6_CIDR, nil]
property :cluster_store, [String, nil]
property :cluster_advertise, [String, nil]
property :cluster_store_opts, ArrayType
property :daemon, [true, false], default: true
property :data_root, [String, nil]
property :debug, [true, false, nil]
property :dns, ArrayType
property :dns_search, [Array, nil]
property :exec_driver, ['native', 'lxc', nil]
property :exec_opts, ArrayType
property :fixed_cidr, [String, nil]
property :fixed_cidr_v6, [String, nil]
property :group, [String], default: 'docker'
property :host, [String, Array], coerce: proc { |v| coerce_host(v) }
property :icc, [true, false, nil]
property :insecure_registry, [Array, String, nil], coerce: proc { |v| coerce_insecure_registry(v) }
property :ip, [IPV4_ADDR, IPV6_ADDR, nil]
property :ip_forward, [true, false, nil]
property :ipv4_forward, [true, false], default: true
property :ipv6_forward, [true, false], default: true
property :ip_masq, [true, false, nil]
property :iptables, [true, false, nil]
property :ipv6, [true, false, nil]
property :log_level, [:debug, :info, :warn, :error, :fatal, nil]
property :labels, [String, Array], coerce: proc { |v| coerce_daemon_labels(v) }, desired_state: false
property :log_driver, %w( json-file syslog journald gelf fluentd awslogs splunk none )
property :log_opts, ArrayType
property :mount_flags, [String, nil]
property :mtu, [String, nil]
property :pidfile, String, default: lazy { "/var/run/#{docker_name}.pid" }
property :registry_mirror, [String, nil]
property :storage_driver, ArrayType
property :selinux_enabled, [true, false, nil]
property :storage_opts, ArrayType
property :default_ulimit, ArrayType
property :userland_proxy, [true, false, nil]
property :disable_legacy_registry, [true, false, nil]
property :userns_remap, [String, nil]

# These are options specific to systemd configuration such as
# LimitNOFILE or TasksMax that you may wannt to use to customize
# the environment in which Docker runs.
property :systemd_opts, ArrayType

# These are unvalidated daemon arguments passed in as a string.
property :misc_opts, [String, nil]

# environment variables to set before running daemon
property :http_proxy, [String, nil]
property :https_proxy, [String, nil]
property :no_proxy, [String, nil]
property :tmpdir, [String, nil]

# logging
property :logfile, String, default: '/var/log/docker.log'

# docker-wait-ready timeout
property :service_timeout, Integer, default: 20

alias label labels
alias tlscacert tls_ca_cert
alias tlscert tls_server_cert
alias tlskey tls_server_key
alias tlsverify tls_verify
alias run_group group
alias graph data_root

declare_action_class.class_eval do
  def libexec_dir
    return '/usr/libexec/docker' if node['platform_family'] == 'rhel'
    '/usr/lib/docker'
  end

  def create_docker_wait_ready
    directory libexec_dir do
      owner 'root'
      group 'root'
      mode '0755'
      action :create
    end

    template "#{libexec_dir}/#{docker_name}-wait-ready" do
      source 'default/docker-wait-ready.erb'
      owner 'root'
      group 'root'
      mode '0755'
      variables(
        docker_cmd: docker_cmd,
        libexec_dir: libexec_dir,
        service_timeout: new_resource.service_timeout
      )
      cookbook 'docker'
      action :create
    end
  end
end
