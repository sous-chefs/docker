class Chef
  class Resource
    class DockerServiceUpstart < DockerService
      use_automatic_resource_name

      provides :docker_service, platform: 'ubuntu'
    end
  end
end
