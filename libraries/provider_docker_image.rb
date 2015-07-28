$LOAD_PATH.unshift *Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)]
require 'docker'

class Chef
  class Provider
    class DockerImage < Chef::Provider::LWRPBase
      # register with the resource resolution system
      provides :docker_image if Chef::Provider.respond_to?(:provides)

      def build_from_directory
        i = Docker::Image.build_from_dir(
          new_resource.source,
          'nocache' => new_resource.nocache,
          'rm' => new_resource.rm
        )
        i.tag('repo' => new_resource.repo, 'tag' => new_resource.tag, 'force' => new_resource.force)
      end

      def build_from_dockerfile
        i = Docker::Image.build(
          IO.read(new_resource.source),
          'nocache' => new_resource.nocache,
          'rm' => new_resource.rm
        )
        i.tag('repo' => new_resource.repo, 'tag' => new_resource.tag, 'force' => new_resource.force)
      end

      def build_from_tar
        i = Docker::Image.build_from_tar(
          ::File.open(new_resource.source, 'r'),
          'nocache' => new_resource.nocache,
          'rm' => new_resource.rm
        )
        i.tag('repo' => new_resource.repo, 'tag' => new_resource.tag, 'force' => new_resource.force)
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
        i = Docker::Image.import(new_resource.source)
        i.tag('repo' => new_resource.repo, 'tag' => new_resource.tag, 'force' => new_resource.force)
      rescue Docker::Error => e
        raise e.message
      end

      def pull_image
        Docker::Image.create(
          'fromImage' => new_resource.repo,
          'tag' => new_resource.tag
        )
      rescue Docker::Error => e
        raise e.message
      end

      def push_image
        i = Docker::Image.get("#{new_resource.repo}:#{new_resource.tag}")
        i.push
      rescue Docker::Error => e
        raise e.message
      end

      def remove_image
        i = Docker::Image.get("#{new_resource.repo}:#{new_resource.tag}")
        i.remove(force: new_resource.force, noprune: new_resource.noprune)
      rescue Docker::Error => e
        raise e.message
      end

      def save_image
        Docker::Image.save(new_resource.repo, new_resource.destination)
      rescue Docker::Error, Errno::ENOENT => e
        raise e.message
      end

      #########
      # Actions
      #########

      action :build do
        build_image
        new_resource.updated_by_last_action(true)
      end

      action :build_if_missing do
        next if Docker::Image.exist?("#{new_resource.repo}:#{new_resource.tag}")
        action_build
        new_resource.updated_by_last_action(true)
      end

      action :import do
        next if Docker::Image.exist?("#{new_resource.repo}:#{new_resource.tag}")
        import_image
        new_resource.updated_by_last_action(true)
      end

      action :pull do
        pull_image
        new_resource.updated_by_last_action(true)
      end

      action :pull_if_missing do
        next if Docker::Image.exist?("#{new_resource.repo}:#{new_resource.tag}")
        action_pull
      end

      action :push do
        push_image
        new_resource.updated_by_last_action(true)
      end

      action :remove do
        next unless Docker::Image.exist?("#{new_resource.repo}:#{new_resource.tag}")
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
