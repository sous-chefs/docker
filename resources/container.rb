actions :remove, :restart, :run, :start, :stop, :wait

default_action :run

attribute :image, :name_attribute => true

attribute :attach, :kind_of => [TrueClass, FalseClass]
attribute :cidfile, :kind_of => [String]
attribute :cmd_timeout, :kind_of => [Integer], :default => 60
attribute :command, :kind_of => [String]
attribute :container_name, :kind_of => [String]
attribute :cpu_shares, :kind_of => [Fixnum]
attribute :detach, :kind_of => [TrueClass, FalseClass]
attribute :dns, :kind_of => [String, Array]
attribute :entrypoint, :kind_of => [String]
attribute :env, :kind_of => [String, Array]
attribute :expose, :kind_of => [Fixnum, String, Array]
attribute :hostname, :kind_of => [String]
attribute :id, :kind_of => [String]
attribute :link, :kind_of => [String]
attribute :lxc_conf, :kind_of => [String, Array]
attribute :memory, :kind_of => [Fixnum]
# Fixnum kind_of port attribute is DEPRACATED
attribute :port, :kind_of => [Fixnum, String, Array]
attribute :privileged, :kind_of => [TrueClass, FalseClass]
# public_port attribute is DEPRECATED
attribute :public_port, :kind_of => [Fixnum]
attribute :publish_exposed_ports, :kind_of => [TrueClass, FalseClass], :default => false
attribute :remove_automatically, :kind_of => [TrueClass, FalseClass], :default => false
attribute :running, :kind_of => [TrueClass, FalseClass]
attribute :stdin, :kind_of => [TrueClass, FalseClass]
attribute :tty, :kind_of => [TrueClass, FalseClass]
attribute :user, :kind_of => [String]
attribute :volume, :kind_of => [String, Array]
attribute :volumes_from, :kind_of => [String]
attribute :working_directory, :kind_of => [String]
