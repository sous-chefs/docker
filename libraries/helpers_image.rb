module DockerHelpers
  module Image
    ################
    # Helper methods
    ################

    def build_from_directory
      i = Docker::Image.build_from_dir(
        source,
        {
          'nocache' => nocache,
          'rm' => rm
        },
        connection
      )
      i.tag('repo' => repo, 'tag' => tag, 'force' => force)
    end

    def build_from_dockerfile
      i = Docker::Image.build(
        IO.read(source),
        {
          'nocache' => nocache,
          'rm' => rm
        },
        connection
      )
      i.tag('repo' => repo, 'tag' => tag, 'force' => force)
    end

    def build_from_tar
      i = Docker::Image.build_from_tar(
        ::File.open(source, 'r'),
        {
          'nocache' => nocache,
          'rm' => rm
        },
        connection
      )
      i.tag('repo' => repo, 'tag' => tag, 'force' => force)
    end

    def build_image
      if ::File.directory?(source)
        build_from_directory
      elsif ::File.extname(source) == '.tar'
        build_from_tar
      else
        build_from_dockerfile
      end
    end

    def image_identifier
      "#{repo}:#{tag}"
    end

    def import_image
      retries ||= api_retries
      i = Docker::Image.import(source, {}, connection)
      i.tag('repo' => repo, 'tag' => tag, 'force' => force)
    rescue Docker::Error => e
      retry unless (retries -= 1).zero?
      raise e.message
    end

    def pull_image
      begin
        retries ||= api_retries

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
      retries ||= api_retries
      i = Docker::Image.get(image_identifier, {}, connection)
      i.push
    rescue Docker::Error => e
      retry unless (retries -= 1).zero?
      raise e.message
    end

    def remove_image
      retries ||= api_retries
      i = Docker::Image.get(image_identifier, {}, connection)
      i.remove(force: force, noprune: noprune)
    rescue Docker::Error => e
      retry unless (retries -= 1).zero?
      raise e.message
    end

    def save_image
      retries ||= api_retries
      Docker::Image.save(repo, destination, connection)
    rescue Docker::Error, Errno::ENOENT => e
      retry unless (retries -= 1).zero?
      raise e.message
    end
  end
end
