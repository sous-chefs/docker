class Chef
  class Resource
    class DockerImage < ChefCompat::Resource
      use_automatic_resource_name

      allowed_actions :build, :build_if_missing, :import, :pull, :pull_if_missing, :push, :remove, :save
      default_action :pull

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
    end
  end
end
