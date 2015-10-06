class Chef
  class Resource
    class DockerServiceSystemd < DockerService
      use_automatic_resource_name

      provides :docker_service, platform: 'fedora'

      provides :docker_service, platform: %w(redhat centos scientific) do |node| # ~FC005
        node['platform_version'].to_f >= 7.0
      end

      provides :docker_service, platform: 'debian' do |node|
        node['platform_version'].to_f >= 8.0
      end

      provides :docker_service, platform: 'ubuntu' do |node|
        node['platform_version'].to_f >= 15.04
      end
    end
  end
end
