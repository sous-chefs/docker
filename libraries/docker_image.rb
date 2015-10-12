require 'docker'
require 'helpers_image'

class Chef
  class Resource
    class DockerImage < DockerBase
      use_automatic_resource_name

      # Modify the default of read_timeout from 60 to 120
      property :read_timeout, default: 120

      # https://docs.docker.com/reference/api/docker_remote_api_v1.20/
      property :host, [String, nil]
      property :repo, String, name_property: true, identity: true
      property :tag, String, default: 'latest', identity: true
      property :docker_image, Docker::Image, desired_state: false
      property :force, Boolean, desired_state: false
      # For remove
      property :noprune, Boolean, desired_state: false
      property :nocache, Boolean, desired_state: false
      # For build
      property :rm, Boolean, default: true, desired_state: false
      property :source, String
      # For save
      property :destination, [String, nil]

      include DockerHelpers::Image

      default_action :pull

      action :build do
        build_image
        created_image = build_image
        update_tag(created_image)
      end

      action :build_if_missing do
        return if current_resource
        action_build
      end

      action :import do
        return if current_resource
        converge_by "Import image #{image}" do
          imported_image = with_retries { Docker::Image.import(source, {}, connection) }
        end
        update_tag(imported_image)
      end

      action :pull do
        pull_image
      end

      action :pull_if_missing do
        return if current_resource
        action_pull
      end

      action :push do
        converge_by "Push image #{image}" do
          with_retries { current_image.push }
        end
      end

      action :remove do
        if current_resource
          converge_by "Remove image #{image}" do
            with_retries { current_image.remove(force: force, noprune: noprune) }
          end
        end
      end

      action :save do
        converge_by "Save image #{image}" do
          with_retries { Docker::Image.save(repo, destination, connection) }
        end
      end

      load_current_value do
        begin
          with_retries { docker_image Docker::Image.get(image, connection) }
        rescue Docker::Error::NotFoundError
          current_value_does_not_exist!
        end
      end

      action_class.class_eval do
        include DockerHelpers::Image::Actions
      end
    end
  end
end
