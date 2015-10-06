class Chef
  class Resource
    class DockerTag < ChefCompat::Resource
      use_automatic_resource_name

      allowed_actions :tag
      default_action :tag

      property :target_repo, kind_of: String, name_attribute: true
      property :target_tag, kind_of: String
      property :to_repo, kind_of: String
      property :to_tag, kind_of: String
    end
  end
end
