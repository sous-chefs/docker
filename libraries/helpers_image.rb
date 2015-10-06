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
          'rm' => new_resource.rm
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
          'rm' => new_resource.rm
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
          'rm' => new_resource.rm
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
      retries ||= new_resource.api_retries
      i = Docker::Image.import(new_resource.source, {}, connection)
      i.tag('repo' => new_resource.repo, 'tag' => new_resource.tag, 'force' => new_resource.force)
    rescue Docker::Error => e
      retry unless (retries -= 1).zero?
      raise e.message
    end

    def pull_image
      begin
        retries ||= new_resource.api_retries

        registry_host = parse_registry_host(new_resource.repo)
        creds = node.run_state['docker_auth'] && node.run_state['docker_auth'][registry_host] || (node.run_state['docker_auth'] ||= {})['index.docker.io']

        original_image = Docker::Image.get(image_identifier, {}, connection) if Docker::Image.exist?(image_identifier, {}, connection)
        new_image = Docker::Image.create({ 'fromImage' => image_identifier }, creds, connection)
      rescue Docker::Error => e
        retry unless (retries -= 1).zero?
        raise e.message
      end

      !(original_image && original_image.id.start_with?(new_image.id))
    end

    def push_image
      retries ||= new_resource.api_retries
      i = Docker::Image.get(image_identifier, {}, connection)
      i.push
    rescue Docker::Error => e
      retry unless (retries -= 1).zero?
      raise e.message
    end

    def remove_image
      retries ||= new_resource.api_retries
      i = Docker::Image.get(image_identifier, {}, connection)
      i.remove(force: new_resource.force, noprune: new_resource.noprune)
    rescue Docker::Error => e
      retry unless (retries -= 1).zero?
      raise e.message
    end

    def save_image
      retries ||= new_resource.api_retries
      Docker::Image.save(new_resource.repo, new_resource.destination, connection)
    rescue Docker::Error, Errno::ENOENT => e
      retry unless (retries -= 1).zero?
      raise e.message
    end
  end
end
