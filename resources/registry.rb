actions :login

default_action :login

attribute :server, :name_attribute => true

attribute :cmd_timeout, :kind_of => [Integer], :default => node['docker']['registry_cmd_timeout']
attribute :email, :kind_of => [String]
attribute :password, :kind_of => [String]
attribute :username, :kind_of => [String]
