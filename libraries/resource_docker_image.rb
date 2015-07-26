class Chef
  class Resource
    class DockerImage < Chef::Resource::LWRPBase
      # Manually set the resource name because we're creating the classes
      # manually instead of letting the resource/ and providers/
      # directories auto-name things.
      self.resource_name = :docker_image

      # FIXME: invetory these
      actions :build, :build_if_missing, :import, :load, :pull, :pull_if_missing, :push, :remove, :save, :tag
      default_action :pull_if_missing

      attribute :cmd_timeout, kind_of: Integer, default: 300
      attribute :created, kind_of: String
      attribute :destination, kind_of: String
      attribute :force, kind_of: [TrueClass, FalseClass]
      attribute :id, kind_of: String
      attribute :image_name, name_attribute: true
      attribute :input, kind_of: String
      attribute :no_cache, kind_of: [TrueClass, FalseClass]
      attribute :no_prune, kind_of: [TrueClass, FalseClass]
      attribute :output, kind_of: String
      attribute :registry, kind_of: String
      attribute :repository, kind_of: String
      attribute :rm, kind_of: [TrueClass, FalseClass]
      attribute :source, kind_of: String
      attribute :tag, kind_of: String, default: 'latest'
    end
  end
end
