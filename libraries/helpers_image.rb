module DockerHelpers
  module Image

    # TODO: test image property in serverspec and kitchen
    # TODO: test this logic with rspec
    #
    # If you say:    `repo 'blah'`
    # Image will be: `blah:latest`
    #
    # If you say:    `repo 'blah'; tag '3.1'`
    # Image will be: `blah:3.1`
    #
    # If you say:    `image 'blah'`
    # Repo will be:  `blah`
    # Tag will be:   `latest`
    #
    # If you say:    `image 'blah:3.1'`
    # Repo will be:  `blah`
    # Tag will be:   `3.1`
    #
    def image(image = nil)
      if image
        r, t = image.split(':', 2)
        repo r
        tag t if t
      end
      "#{repo}:#{tag}"
    end

    alias_method :image_name, :image

    ##################
    # Action helpers
    ##################

    module Actions
      def build_image
        opts = { 'nocache' => nocache, 'rm' => rm }
        if ::File.directory?(source)
          type = "directory"
          created_image = Docker::Image.build_from_dir(source, opts, connection)
        elsif ::File.extname(source) == '.tar'
          type = "tarfile"
          created_image = Docker::Image.build_from_tar(::File.open(source, 'r'), opts, connection)
        else
          type = "dockerfile"
          created_image = Docker::Image.build(IO.read(source), opts, connection)
        end

        if current_image && current_image.id == created_image.id
          load_current_resource
          true
        end
      end

      def current_image
        current_resource && current_resource.docker_image
      end

      def pull_image
        registry_host = parse_registry_host(repo)
        creds = node.run_state['docker_auth'] && node.run_state['docker_auth'][registry_host] || (node.run_state['docker_auth'] ||= {})['index.docker.io']

        if current_image
          new_image = with_retries { Docker::Image.create({ 'fromImage' => image }, creds, connection) }

          # We already did the work, but we need to report it now (assuming we
          # really did do work). (current_image is the image we started with.)
          unless current_image && current_image.id.start_with?(new_image.id)
            converge_by "Pull image #{image_identifier}" do
            end
          end
        end

        update_tag(new_image)
      end

      def update_tag(to_image)
        # Only tag the image if it is different from what we already have
        unless current_image && current_image.id.start_with?(to_image.id)
          converge_by "Tag image #{image}#{force ? " (force)" : ""}" do
            to_image.tag('repo' => repo, 'tag' => tag, 'force' => force)
          end
        end
      end
    end
  end
end
