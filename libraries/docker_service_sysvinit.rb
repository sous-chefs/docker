class Chef
  class Resource
    class DockerServiceSysvinit < DockerService
      use_automatic_resource_name

      provides :docker_service, platform: 'amazon'
      provides :docker_service, platform: 'centos'
      provides :docker_service, platform: 'redhat'
      provides :docker_service, platform: 'suse'
      provides :docker_service, platform: 'debian'
    end
  end
end
