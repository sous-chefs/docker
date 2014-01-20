actions :build, :import, :insert, :load, :pull, :push, :remove, :save, :tag

default_action :pull

attribute :image_name, :name_attribute => true

attribute :cmd_timeout, :kind_of => [Integer], :default => node['docker']['image_cmd_timeout']
attribute :destination, :kind_of => [String]
# DEPRECATED: Use source attribute
attribute :dockerfile, :kind_of => [String]
attribute :force, :kind_of => [TrueClass, FalseClass], :default => false
attribute :id, :kind_of => [String]
# DEPRECATED: Use source attribute
attribute :image_url, :kind_of => [String]
attribute :installed, :kind_of => [TrueClass, FalseClass]
attribute :installed_tag, :kind_of => [String]
attribute :no_cache, :kind_of => [TrueClass, FalseClass], :default => false
# DEPRECATED: Use source attribute
attribute :path, :kind_of => [String]
attribute :registry, :kind_of => [String]
attribute :repository, :kind_of => [String]
attribute :rm, :kind_of => [TrueClass, FalseClass], :default => false
attribute :source, :kind_of => [String]
attribute :tag, :kind_of => [String]
