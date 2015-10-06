class Chef
  class Resource
    class DockerTag < ChefCompat::Resource
      use_automatic_resource_name

      property :target_repo, String, name_attribute: true
      property :target_tag, String
      property :to_repo, String
      property :to_tag, String

      #########
      # Actions
      #########

      action :tag do
        next if Docker::Image.exist?("#{new_resource.to_repo}:#{new_resource.to_tag}")
        begin
          i = Docker::Image.get("#{new_resource.target_repo}:#{new_resource.target_tag}")
          i.tag('repo' => new_resource.to_repo, 'tag' => new_resource.to_tag, 'force' => true)
        rescue Docker::Error => e
          raise e.message
        end
        new_resource.updated_by_last_action(true)
      end
    end
  end
end
