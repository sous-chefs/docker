module DockerCookbook
  module DockerHelpers
    module Image
      ################
      # Helper methods
      ################

      def build_from_directory
        i = Docker::Image.build_from_dir(
          new_resource.source,
          {
            'nocache' => new_resource.nocache,
            'rm' => new_resource.rm,
          },
          connection
        )
        i.tag('repo' => new_resource.repo, 'tag' => new_resource.tag, 'force' => new_resource.force)
      end

      def build_from_dockerfile
        i = Docker::Image.build(
          IO.read(new_resource.source),
          {
            'nocache' => new_resource.nocache,
            'rm' => new_resource.rm,
          },
          connection
        )
        i.tag('repo' => new_resource.repo, 'tag' => new_resource.tag, 'force' => new_resource.force)
      end

      def build_from_tar
        i = Docker::Image.build_from_tar(
          ::File.open(new_resource.source, 'r'),
          {
            'nocache' => new_resource.nocache,
            'rm' => new_resource.rm,
          },
          connection
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

      def image_identifier
        "#{new_resource.repo}:#{new_resource.tag}"
      end

      def import_image
        with_retries do
          i = Docker::Image.import(new_resource.source, {}, connection)
          i.tag('repo' => new_resource.repo, 'tag' => new_resource.tag, 'force' => new_resource.force)
        end
      end

      def pull_image
        with_retries do
          creds = credentails
          original_image = Docker::Image.get(image_identifier, {}, connection) if Docker::Image.exist?(image_identifier, {}, connection)
          new_image = Docker::Image.create({ 'fromImage' => image_identifier }, creds, connection)

          !(original_image && original_image.id.start_with?(new_image.id))
        end
      end

      def push_image
        with_retries do
          creds = credentails
          i = Docker::Image.get(image_identifier, {}, connection)
          i.push(creds, repo_tag: image_identifier)
        end
      end

      def remove_image
        with_retries do
          i = Docker::Image.get(image_identifier, {}, connection)
          i.remove(force: new_resource.force, noprune: new_resource.noprune)
        end
      end

      def save_image
        with_retries do
          Docker::Image.save(new_resource.repo, new_resource.destination, connection)
        end
      end

      def load_image
        with_retries do
          Docker::Image.load(new_resource.source, {}, connection)
        end
      end

      def credentails
        registry_host = parse_registry_host(new_resource.repo)
        creds = node.run_state['docker_auth'] && node.run_state['docker_auth'][registry_host] || (node.run_state['docker_auth'] ||= {})['index.docker.io']
        creds
      end
    end
  end
end
