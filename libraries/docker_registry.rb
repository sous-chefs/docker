class Chef
  class Resource
    class DockerRegistry < ChefCompat::Resource
      use_automatic_resource_name

      allowed_actions :login
      default_action :login

      property :api_retries, kind_of: Fixnum, default: 3
      property :email, kind_of: String
      property :password, kind_of: String
      property :serveraddress, kind_of: String, name_attribute: true
      property :username, kind_of: String
    end
  end
end
