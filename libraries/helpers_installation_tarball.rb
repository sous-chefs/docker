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
        "https://download.docker.com/#{docker_kernel.downcase}/static/#{channel}/#{docker_arch}/docker-#{version}-ce.tgz"
      end

      def default_checksum
        case docker_kernel
        when 'Darwin'
          case version
          when '17.12.0' then 'dc673421e0368c2c970203350a9d0cb739bc498c897e832779369b0b2a9c6192'
          end
        when 'Linux'
          case version
          when '17.12.0' then '692e1c72937f6214b1038def84463018d8e320c8eaf8530546c84c2f8f9c767d'
          end
        end
      end
    end
  end
end
