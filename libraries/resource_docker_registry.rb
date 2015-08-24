class Chef
  class Resource
    class DockerRegistry < Chef::Resource::LWRPBase
      self.resource_name = :docker_registry

      actions :login
      default_action :login

      attribute :api_retries, kind_of: Fixnum, default: 3
      attribute :email, kind_of: String
      attribute :password, kind_of: String
      attribute :serveraddress, kind_of: String, name_attribute: true
      attribute :username, kind_of: String
    end
  end
end
