class Chef
  class Resource
    class DockerRegistry < Chef::Resource::LWRPBase
      def initialize(*args)
        super
        @retries = 2
      end

      self.resource_name = :docker_registry

      actions :login
      default_action :login

      attribute :serveraddress, kind_of: String, name_attribute: true
      attribute :username, kind_of: String
      attribute :password, kind_of: String
      attribute :email, kind_of: String
    end
  end
end
