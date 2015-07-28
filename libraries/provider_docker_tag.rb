$LOAD_PATH.unshift *Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)]
require 'docker'

class Chef
  class Provider
    class DockerTag < Chef::Provider::LWRPBase
      # register with the resource resolution system
      provides :docker_tag if Chef::Provider.respond_to?(:provides)

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
