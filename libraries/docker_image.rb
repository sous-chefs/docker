require 'docker'
require 'helpers_image'

class Chef
  class Resource
    class DockerImage < DockerBase
      use_automatic_resource_name

      # https://docs.docker.com/reference/api/docker_remote_api_v1.20/
      property :api_retries, kind_of: Fixnum, default: 3
      property :destination, kind_of: String, default: nil
      property :force, kind_of: [TrueClass, FalseClass], default: false
      property :host, kind_of: String, default: nil
      property :nocache, kind_of: [TrueClass, FalseClass], default: false
      property :noprune, kind_of: [TrueClass, FalseClass], default: false
      property :read_timeout, kind_of: [Fixnum, NilClass], default: 120
      property :repo, kind_of: String, name_attribute: true
      property :rm, kind_of: [TrueClass, FalseClass], default: true
      property :source, kind_of: String
      property :tag, kind_of: String, default: 'latest'
      property :write_timeout, kind_of: [Fixnum, NilClass], default: nil

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
