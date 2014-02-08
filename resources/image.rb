actions :build, :build_if_missing, :import, :insert, :load, :pull, :pull_if_missing, :push, :remove, :save, :tag

default_action :pull

attribute :image_name, :name_attribute => true

attribute :cmd_timeout, :kind_of => [Integer], :default => node['docker']['image_cmd_timeout']
attribute :created, :kind_of => [String]
attribute :destination, :kind_of => [String]
# DEPRECATED: Use source attribute
attribute :dockerfile, :kind_of => [String]
attribute :force, :kind_of => [TrueClass, FalseClass], :default => false
attribute :id, :kind_of => [String]
# DEPRECATED: Use source attribute
attribute :image_url, :kind_of => [String]
attribute :no_cache, :kind_of => [TrueClass, FalseClass], :default => false
# DEPRECATED: Use source attribute
attribute :path, :kind_of => [String]
attribute :registry, :kind_of => [String]
attribute :repository, :kind_of => [String]
attribute :rm, :kind_of => [TrueClass, FalseClass], :default => false
attribute :source, :kind_of => [String]
attribute :tag, :kind_of => [String]
attribute :virtual_size, :kind_of => [String]
