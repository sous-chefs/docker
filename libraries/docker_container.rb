class Chef
  class Resource
    class DockerContainer < ChefCompat::Resource
      use_automatic_resource_name

      allowed_actions :create, :start, :stop, :kill, :run, :pause, :unpause, :restart, :delete, :redeploy, :run_if_missing, :remove_link
      default_action :run_if_missing

      property :container_name, kind_of: String, name_attribute: true
      property :repo, kind_of: String, default: nil
      property :tag, kind_of: String, default: 'latest'
      property :command, kind_of: [String, Array], default: ''

      property :api_retries, kind_of: Fixnum, default: 3
      property :attach_stderr, kind_of: [TrueClass, FalseClass], default: true
      property :attach_stdin, kind_of: [TrueClass, FalseClass], default: false
      property :attach_stdout, kind_of: [TrueClass, FalseClass], default: true
      property :autoremove, kind_of: [TrueClass, FalseClass], default: false
      property :binds, kind_of: [String, Array, NilClass], default: nil # FIXME: add validate proc
      property :cap_add, kind_of: [String, Array, NilClass], default: nil # FIXME: add validate proc
      property :cap_drop, kind_of: [String, Array, NilClass], default: nil # FIXME: add validate proc
      property :cgroup_parent, kind_of: String, default: '' # FIXME: add validate proc
      property :cpu_shares, kind_of: [Fixnum, NilClass], default: 0 # FIXME: add validate proc
      property :cpuset_cpus, kind_of: String, default: '' # FIXME: add validate proc
      property :detach, kind_of: [TrueClass, FalseClass], default: true
      property :devices, kind_of: [Hash, Array, NilClass], default: nil # FIXME: add validate proc
      property :dns, kind_of: [String, Array, NilClass], default: nil
      property :dns_search, kind_of: [String, Array, NilClass], default: nil
      property :domain_name, kind_of: String, default: ''
      property :entrypoint, kind_of: [String, Array, NilClass], default: nil
      property :env, kind_of: [String, Array], default: nil
      property :extra_hosts, kind_of: [String, Array, NilClass], default: nil
      property :exposed_ports, kind_of: Hash, default: nil
      property :force, kind_of: [TrueClass, FalseClass], default: false
      property :host, kind_of: String, default: nil
      property :host_name, kind_of: String, default: nil
      property :labels, kind_of: [String, Array, Hash], default: nil
      property :links, kind_of: [String, Array, NilClass], default: nil # FIXME: add validate proc
      property :log_config, kind_of: [Hash, NilClass], default: nil # FIXME: add validate proc and tests; to configure the resource, prefer log_driver/log_opts below
      property :log_driver, equal_to: %w( json-file syslog journald gelf fluentd none ), default: nil
      property :log_opts, kind_of: [String, Array], default: []
      property :mac_address, kind_of: String, default: '' # FIXME: needs tests
      property :memory, kind_of: Fixnum, default: 0
      property :memory_swap, kind_of: Fixnum, default: -1
      property :network_disabled, kind_of: [TrueClass, FalseClass], default: false
      property :network_mode, kind_of: [String, NilClass], default: nil
      property :open_stdin, kind_of: [TrueClass, FalseClass], default: false
      property :outfile, kind_of: String, default: nil
      property :port, kind_of: [String, Array], default: nil
      property :port_bindings, kind_of: [String, Array, Hash], default: nil
      property :privileged, kind_of: [TrueClass, FalseClass], default: false
      property :publish_all_ports, kind_of: [TrueClass, FalseClass], default: false
      property :read_timeout, kind_of: [Fixnum, NilClass], default: 60
      property :remove_volumes, kind_of: [TrueClass, FalseClass], default: false
      property :restart_maximum_retry_count, kind_of: Fixnum, default: 0
      property :restart_policy, kind_of: [String, Hash, NilClass], default: 'no' # FIXME: validation proc: equal_to: %w(no on-failure always)
      property :security_opts, kind_of: [String, Array], default: ['']
      property :signal, kind_of: String, default: 'SIGKILL'
      property :stdin_once, kind_of: [TrueClass, FalseClass, NilClass], default: false
      property :timeout, kind_of: Fixnum, default: nil
      property :tty, kind_of: [TrueClass, FalseClass], default: false
      property :ulimits, kind_of: [Hash, Array, String, NilClass], default: nil
      property :user, kind_of: String, default: ''
      property :volumes, kind_of: [String, Array, Hash, NilClass], default: nil # FIXME: add validate proc
      property :volumes_from, kind_of: [String, Array, NilClass], default: nil # FIXME: add validate proc
      property :working_dir, kind_of: String, default: nil
      property :write_timeout, kind_of: [Fixnum, NilClass], default: nil

      alias_method :cmd, :command
      alias_method :image, :repo
      alias_method :image_name, :repo
      alias_method :additional_host, :extra_hosts
      alias_method :rm, :autoremove
      alias_method :remove_automatically, :autoremove
      alias_method :hostname, :host_name
      alias_method :domainname, :domain_name
      alias_method :dnssearch, :dns_search
      alias_method :restart_maximum_retries, :restart_maximum_retry_count
      alias_method :api_retries, :restart_maximum_retry_count
      alias_method :volume, :volumes
      alias_method :volume_from, :volumes_from
      alias_method :destination, :outfile
      alias_method :workdir, :working_dir
    end
  end
end
