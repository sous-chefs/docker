actions :remove, :restart, :run, :start, :stop

default_action :run

attribute :image, :name_attribute => true

attribute :cmd_timeout, :kind_of => [Integer], :default => 60
attribute :command, :kind_of => [String]
attribute :detach, :kind_of => [TrueClass, FalseClass]
attribute :env, :kind_of => [String]
attribute :hostname, :kind_of => [String]
attribute :id, :kind_of => [String]
attribute :memory, :kind_of => [Fixnum]
attribute :port, :kind_of => [Fixnum]
attribute :privileged, :kind_of => [TrueClass, FalseClass]
attribute :public_port, :kind_of => [Fixnum]
attribute :running, :kind_of => [TrueClass, FalseClass]
attribute :stdin, :kind_of => [TrueClass, FalseClass]
attribute :tty, :kind_of => [TrueClass, FalseClass]
attribute :user, :kind_of => [String]
attribute :volume, :kind_of => [String]
attribute :working_directory, :kind_of => [String]
