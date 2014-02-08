actions :commit, :cp, :export, :kill, :redeploy, :remove, :restart, :run, :start, :stop, :wait

default_action :run

attribute :image, :name_attribute => true

attribute :attach, :kind_of => [TrueClass, FalseClass]
attribute :author, :kind_of => [String]
attribute :cidfile, :kind_of => [String]
attribute :cmd_timeout, :kind_of => [Integer], :default => node['docker']['container_cmd_timeout']
attribute :command, :kind_of => [String]
attribute :container_name, :kind_of => [String]
attribute :cookbook, :kind_of => [String], :default => 'docker'
attribute :created, :kind_of => [String]
attribute :cpu_shares, :kind_of => [Fixnum]
attribute :destination, :kind_of => [String]
attribute :detach, :kind_of => [TrueClass, FalseClass]
attribute :dns, :kind_of => [String, Array]
attribute :entrypoint, :kind_of => [String]
attribute :env, :kind_of => [String, Array]
attribute :expose, :kind_of => [Fixnum, String, Array]
attribute :hostname, :kind_of => [String]
attribute :id, :kind_of => [String]
attribute :init_type, :kind_of => [FalseClass, String], :default => node['docker']['container_init_type']
attribute :init_template, :kind_of => [String]
attribute :link, :kind_of => [String, Array]
attribute :lxc_conf, :kind_of => [String, Array]
attribute :memory, :kind_of => [Fixnum]
attribute :message, :kind_of => [String]
# Fixnum kind_of port attribute is DEPRECATED
attribute :port, :kind_of => [Fixnum, String, Array]
attribute :privileged, :kind_of => [TrueClass, FalseClass]
# public_port attribute is DEPRECATED
attribute :public_port, :kind_of => [Fixnum]
attribute :publish_exposed_ports, :kind_of => [TrueClass, FalseClass], :default => false
attribute :remove_automatically, :kind_of => [TrueClass, FalseClass], :default => false
attribute :repository, :kind_of => [String]
attribute :run, :kind_of => [String]
attribute :socket_template, :kind_of => [String]
attribute :source, :kind_of => [String]
attribute :status, :kind_of => [String]
attribute :stdin, :kind_of => [TrueClass, FalseClass]
attribute :tag, :kind_of => [String]
attribute :tty, :kind_of => [TrueClass, FalseClass]
attribute :user, :kind_of => [String]
attribute :volume, :kind_of => [String, Array]
attribute :volumes_from, :kind_of => [String]
attribute :working_directory, :kind_of => [String]
