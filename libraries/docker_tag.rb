class Chef
  class Resource
    class DockerTag < Chef::Resource::LWRPBase
      # Manually set the resource name because we're creating the classes
      # manually instead of letting the resource/ and providers/
      # directories auto-name things.
      self.resource_name = :docker_tag

      actions :tag
      default_action :tag

      attribute :target_repo, kind_of: String, name_attribute: true
      attribute :target_tag, kind_of: String
      attribute :to_repo, kind_of: String
      attribute :to_tag, kind_of: String
    end
  end
end
