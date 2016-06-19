module DockerCookbook
  module DockerHelpers
    module InstallationTarball
      def docker_bin_prefix
        '/usr/bin'
      end

      def docker_bin
        "#{docker_bin_prefix}/docker"
      end

      def docker_tarball
        "#{Chef::Config[:file_cache_path]}/docker-#{version}.tgz"
      end

      def docker_kernel
        node['kernel']['name']
      end

      def docker_arch
        node['kernel']['machine']
      end

      def default_source
        "https://get.docker.com/builds/#{docker_kernel}/#{docker_arch}/docker-#{version}.tgz"
      end

      def default_checksum
        case docker_kernel
        when 'Darwin'
          case version
          when '1.11.0' then '25e4f5f37e2e17beb20e5a468674750350824059bdeeca09d6a941bca8fc4f73'
          when '1.11.1' then '6d35487fbcc7e3f722f3d5f3e5c070a41d87c88e3770f52ae28460a689c40efd'
          end
        when 'Linux'
          case version
          when '1.11.0' then '87331b3b75d32d3de5d507db9a19a24dd30ff9b2eb6a5a9bdfaba954da15e16b'
          when '1.11.1' then '893e3c6e89c0cd2c5f1e51ea41bc2dd97f5e791fcfa3cee28445df277836339d'
          end
        end
      end

      def default_version
        '1.11.1'
      end
    end
  end
end
