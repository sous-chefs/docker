actions :pull, :remove, :build, :import

default_action :pull

attribute :image_name, :name_attribute => true

attribute :cmd_timeout, :kind_of => [Integer], :default => node['docker']['image_cmd_timeout']
attribute :dockerfile, :kind_of => [String]
attribute :id, :kind_of => [String]
attribute :image_url, :kind_of => [String]
attribute :installed, :kind_of => [TrueClass, FalseClass]
attribute :installed_tag, :kind_of => [String]
attribute :path, :kind_of => [String]
attribute :registry, :kind_of => [String]
attribute :repository, :kind_of => [String]
attribute :tag, :kind_of => [String]
