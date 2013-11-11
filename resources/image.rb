actions :pull, :remove, :build, :import

default_action :pull

attribute :image_name, :name_attribute => true
attribute :id, :kind_of => [String]
attribute :installed, :kind_of => [TrueClass, FalseClass]
attribute :installed_tag, :kind_of => [String]
attribute :registry, :kind_of => [String]
attribute :repository, :kind_of => [String]
attribute :tag, :kind_of => [String]
attribute :dockerfile, :kind_of => [String]
attribute :image_url, :kind_of => [String]
attribute :cmd_timeout, :kind_of => [Integer], :default => 60
attribute :path, :kind_of => [String]
