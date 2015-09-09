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
          cred_stash ||= Docker.creds
          retries ||= new_resource.api_retries
          api_timeouts
          o = Docker::Image.get(image_identifier) if Docker::Image.exist?(image_identifier)
          i = Docker::Image.create(
            'fromImage' => new_resource.repo,
            'tag' => new_resource.tag
          )
        rescue Docker::Error::ArgumentError => e
          # Dirty hack around what seems to be a bug (feature?) in
          # docker-api authentication header handling when pulling
          # from the public registry with invalid creds are set
          Docker.creds = {}
          retry unless (retries -= 1).zero?
          raise e.message
        ensure
          Docker.creds = cred_stash
        end
        return false if o && o.id =~ /^#{i.id}/
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
