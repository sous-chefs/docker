class Chef
  class Resource
    class DockerImage < Chef::Resource::LWRPBase
      # Manually set the resource name because we're creating the classes
      # manually instead of letting the resource/ and providers/
      # directories auto-name things.
      self.resource_name = :docker_image

      actions :build, :build_if_missing, :import, :pull, :pull_if_missing, :push, :remove, :save
      default_action :pull

      # https://docs.docker.com/reference/api/docker_remote_api_v1.20/
      attribute :api_retries, kind_of: Fixnum, default: 3
      attribute :destination, kind_of: String, default: nil
      attribute :force, kind_of: [TrueClass, FalseClass], default: false
      attribute :nocache, kind_of: [TrueClass, FalseClass], default: false
      attribute :noprune, kind_of: [TrueClass, FalseClass], default: false
      attribute :read_timeout, kind_of: [Fixnum, NilClass], default: 120
      attribute :repo, kind_of: String, name_attribute: true
      attribute :rm, kind_of: [TrueClass, FalseClass], default: true
      attribute :source, kind_of: String
      attribute :tag, kind_of: String, default: 'latest'
      attribute :write_timeout, kind_of: [Fixnum, NilClass], default: nil

      alias_method :image, :repo
      alias_method :image_name, :repo
      alias_method :no_cache, :nocache
      alias_method :no_prune, :noprune
    end
  end
end
