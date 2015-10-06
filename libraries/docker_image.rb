require 'docker'
require 'helpers_image'

class Chef
  class Resource
    class DockerImage < DockerBase
      use_automatic_resource_name

      # https://docs.docker.com/reference/api/docker_remote_api_v1.20/
      property :api_retries, Fixnum, default: 3
      property :destination, String, default: nil
      property :force, [true, false], default: false
      property :host, String, default: nil
      property :nocache, [true, false], default: false
      property :noprune, [true, false], default: false
      property :read_timeout, [Fixnum, nil], default: 120
      property :repo, String, name_attribute: true
      property :rm, [true, false], default: true
      property :source, String
      property :tag, String, default: 'latest'
      property :write_timeout, [Fixnum, nil], default: nil

      alias_method :image, :repo
      alias_method :image_name, :repo
      alias_method :no_cache, :nocache
      alias_method :no_prune, :noprune

      #########
      # Actions
      #########

      default_action :pull

      declare_action_class.class_eval do
        include DockerHelpers::Image
      end

      action :build do
        build_image
        new_resource.updated_by_last_action(true)
      end

      action :build_if_missing do
        next if Docker::Image.exist?(image_identifier, {}, connection)
        action_build
        new_resource.updated_by_last_action(true)
      end

      action :import do
        next if Docker::Image.exist?(image_identifier, {}, connection)
        import_image
        new_resource.updated_by_last_action(true)
      end

      action :pull do
        r = pull_image
        new_resource.updated_by_last_action(r)
      end

      action :pull_if_missing do
        next if Docker::Image.exist?(image_identifier, {}, connection)
        action_pull
      end

      action :push do
        push_image
        new_resource.updated_by_last_action(true)
      end

      action :remove do
        next unless Docker::Image.exist?(image_identifier, {}, connection)
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
