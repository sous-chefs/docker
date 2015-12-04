module DockerCookbook
  class DockerImage < DockerBase
    require 'docker'
    require 'helpers_image'

    use_automatic_resource_name

    # Modify the default of read_timeout from 60 to 120
    property :read_timeout, default: 120, desired_state: false

    # https://docs.docker.com/reference/api/docker_remote_api_v1.20/
    property :destination, [String, nil]
    property :force, Boolean, default: false
    property :host, [String], default: lazy { default_host }, desired_state: false
    property :nocache, Boolean, default: false
    property :noprune, Boolean, default: false
    property :repo, String, name_property: true
    property :rm, Boolean, default: true
    property :source, String
    property :tag, String, default: 'latest'

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
      def whyrun_supported?
        true
      end
    end

    action :build do
      converge_by "Build image #{image_identifier}" do
        build_image
      end
    end

    action :build_if_missing do
      return if Docker::Image.exist?(image_identifier, {}, connection)
      action_build
    end

    action :import do
      return if Docker::Image.exist?(image_identifier, {}, connection)
      converge_by "Import image #{image_identifier}" do
        import_image
      end
    end

    action :pull do
      # We already did the work, but we need to report what we did!
      converge_by "Pull image #{image_identifier}" do
      end if pull_image
    end

    action :pull_if_missing do
      return if Docker::Image.exist?(image_identifier, {}, connection)
      action_pull
    end

    action :push do
      converge_by "Push image #{image_identifier}" do
        push_image
      end
    end

    action :remove do
      return unless Docker::Image.exist?(image_identifier, {}, connection)
      converge_by "Remove image #{image_identifier}" do
        remove_image
      end
    end

    action :save do
      converge_by "Save image #{image_identifier}" do
        save_image
      end
    end
  end
end
