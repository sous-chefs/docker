class Chef
  class Resource
    class DockerServiceExecute < DockerService
      use_automatic_resource_name

      provides :docker_service, os: 'linux'
    end
  end
end
