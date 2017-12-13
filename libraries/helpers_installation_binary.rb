module DockerCookbook
  module DockerHelpers
    module InstallationBinary
      def docker_bin
        '/usr/bin/docker'
      end

      def docker_kernel
        node['kernel']['name']
      end

      def docker_arch
        node['kernel']['machine']
      end

      def default_source
        "https://get.docker.com/builds/#{docker_kernel}/#{docker_arch}/docker-#{version}"
      end

      def default_checksum
        case docker_kernel
        when 'Darwin'
          case version
          when '1.10.0' then 'f8dc0c7ef2a7efbe0e062017822066e55a40c752b9e92a636359f59ef562d79f'
          when '1.10.1' then 'de4057057acd259ec38b5244a40d806993e2ca219e9869ace133fad0e09cedf2'
          when '1.10.2' then '29249598587ad8f8597235bbeb11a11888fffb977b8089ea80b5ac5267ba9f2e'
          end
        when 'Linux'
          case version
          when '1.10.0' then 'a66b20423b7d849aa8ef448b98b41d18c45a30bf3fe952cc2ba4760600b18087'
          when '1.10.1' then 'de4057057acd259ec38b5244a40d806993e2ca219e9869ace133fad0e09cedf2'
          when '1.10.2' then '3fcac4f30e1c1a346c52ba33104175ae4ccbd9b9dbb947f56a0a32c9e401b768'
          end
        end
      end

      def default_version
        '1.10.2'
      end
    end
  end
end
