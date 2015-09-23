$LOAD_PATH.unshift *Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)]
require 'docker'

class Chef
  class Provider
    class DockerImage < Chef::Provider::LWRPBase
      # register with the resource resolution system
      provides :docker_image if Chef::Provider.respond_to?(:provides)

      ################
      # Helper methods
      ################

      def api_timeouts
        Docker.options[:read_timeout] = new_resource.read_timeout unless new_resource.read_timeout.nil?
        Docker.options[:write_timeout] = new_resource.write_timeout unless new_resource.write_timeout.nil?
      end

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
        api_timeouts
        if ::File.directory?(new_resource.source)
          build_from_directory
        elsif ::File.extname(new_resource.source) == '.tar'
          build_from_tar
        else
          build_from_dockerfile
        end
      end

      def image_identifier
        "#{new_resource.repo}:#{new_resource.tag}"
      end

      def import_image
        api_timeouts
        retries ||= new_resource.api_retries
        i = Docker::Image.import(new_resource.source)
        i.tag('repo' => new_resource.repo, 'tag' => new_resource.tag, 'force' => new_resource.force)
      rescue Docker::Error => e
        retry unless (retries -= 1).zero?
        raise e.message
      end

      def pull_image
        begin
          retries ||= new_resource.api_retries
          api_timeouts

          # https://github.com/docker/docker/blob/4fcb9ac40ce33c4d6e08d5669af6be5e076e2574/registry/auth.go#L231
          registry_host = new_resource.repo.sub(%r{https?://}, '').split('/').first

          Docker::Image.create({ 'fromImage' => image_identifier },
                               node.run_state[:docker_auth] && node.run_state[:docker_auth][registry_host])
        rescue Docker::Error => e
          retry unless (retries -= 1).zero?
          raise e.message
        end

        true
      end

      def push_image
        api_timeouts
        retries ||= new_resource.api_retries
        i = Docker::Image.get(image_identifier)
        i.push
      rescue Docker::Error => e
        retry unless (retries -= 1).zero?
        raise e.message
      end

      def remove_image
        api_timeouts
        retries ||= new_resource.api_retries
        i = Docker::Image.get(image_identifier)
        i.remove(force: new_resource.force, noprune: new_resource.noprune)
      rescue Docker::Error => e
        retry unless (retries -= 1).zero?
        raise e.message
      end

      def save_image
        api_timeouts
        retries ||= new_resource.api_retries
        Docker::Image.save(new_resource.repo, new_resource.destination)
      rescue Docker::Error, Errno::ENOENT => e
        retry unless (retries -= 1).zero?
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
        next if Docker::Image.exist?(image_identifier)
        action_build
        new_resource.updated_by_last_action(true)
      end

      action :import do
        next if Docker::Image.exist?(image_identifier)
        import_image
        new_resource.updated_by_last_action(true)
      end

      action :pull do
        r = pull_image
        new_resource.updated_by_last_action(r)
      end

      action :pull_if_missing do
        next if Docker::Image.exist?(image_identifier)
        action_pull
      end

      action :push do
        push_image
        new_resource.updated_by_last_action(true)
      end

      action :remove do
        next unless Docker::Image.exist?(image_identifier)
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
