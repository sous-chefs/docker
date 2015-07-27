$:.unshift *Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)]
require 'docker'

class Chef
  class Provider
    class DockerImage < Chef::Provider::LWRPBase
      # register with the resource resolution system
      if Chef::Provider.respond_to?(:provides)
        provides :docker_image
      end

      def build_from_directory
        i = Docker::Image.build_from_dir(new_resource.source)
        i.tag('repo' => new_resource.image_name, 'tag' => new_resource.tag, 'force' => true)
      end

      def build_from_dockerfile
        i = Docker::Image.build(IO.read(new_resource.source))
        i.tag('repo' => new_resource.image_name, 'tag' => new_resource.tag, 'force' => true)
      end

      def build_from_tar
        i = Docker::Image.build_from_tar(::File.open(new_resource.source, 'r'))
        i.tag('repo' => new_resource.image_name, 'tag' => new_resource.tag, 'force' => true)
      end

      def build_image       
        if ::File.directory?(new_resource.source)
          build_from_directory
        elsif ::File.extname(new_resource.source) == '.tar'
          build_from_tar
        else
          build_from_dockerfile
        end
      end

      def import_image
        begin
          i = Docker::Image.import(new_resource.source)
          i.tag('repo' => new_resource.image_name, 'tag' => new_resource.tag, 'force' => true)
        rescue Docker::Error => e
          fail e.message
        end
      end

      def pull_image
        begin
          Docker::Image.create(
            'fromImage' => new_resource.image_name,
            'tag' => new_resource.tag
            )
        rescue Docker::Error => e
          fail e.message
        end
      end

      def remove_image
        begin
          i = Docker::Image.get(new_resource.image_name)
          i.remove
        rescue Docker::Error => e
          fail e.message
        end
      end

      def save_image
        begin
          Docker::Image.save(new_resource.image_name, new_resource.destination)
        rescue Docker::Error, Errno::ENOENT => e
          fail e.message
        end
      end

      #########
      # Actions
      #########

      action :build do
        build_image
        new_resource.updated_by_last_action(true)
      end

      action :build_if_missing do
        next if Docker::Image.exist?("#{new_resource.image_name}:#{new_resource.tag}")
        action_build
        new_resource.updated_by_last_action(true)
      end

      action :import do
        next if Docker::Image.exist?("#{new_resource.image_name}:#{new_resource.tag}")
        import_image
        new_resource.updated_by_last_action(true)
      end

      action :pull do
        pull_image
        new_resource.updated_by_last_action(true)
      end

      action :pull_if_missing do
        next if Docker::Image.exist?("#{new_resource.image_name}:#{new_resource.tag}")
        action_pull
      end

      # action :push do
      # end

      action :remove do
        next unless Docker::Image.exist?("#{new_resource.image_name}:#{new_resource.tag}")
        remove_image
        new_resource.updated_by_last_action(true)
      end

      action :save do
        save_image
        new_resource.updated_by_last_action(true)
      end

    end
  end
end
