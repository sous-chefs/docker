module DockerCookbook
  module DockerHelpers
    module InstallationPackage
      def el6?
        return true if node['platform_family'] == 'rhel' && node['platform_version'].to_i == 6
        false
      end

      def el7?
        return true if node['platform_family'] == 'rhel' && node['platform_version'].to_i == 7
        false
      end

      def fedora?
        return true if node['platform'] == 'fedora'
        false
      end

      def amazon?
        return true if node['platform'] == 'amazon'
        false
      end

      def debuntu?
        return true if node['platform_family'] == 'debian'
        return true if node['platform_family'] == 'ubuntu'
        false
      end

      def precise?
        return true if node['platform'] == 'ubuntu' && node['platform_version'] == '12.04'
        false
      end

      # https://github.com/chef/chef/issues/4103
      def version_string(v)
        precise_prefix = if Gem::Version.new(v) > Gem::Version.new('1.12.3')
                           'ubuntu-'
                         else
                           ''
                         end

        edition = if Gem::Version.new(v) > Gem::Version.new('17.03.0')
                    if debuntu?
                      '~ce'
                    elsif amazon?
                      'ce'
                    else
                      '.ce'
                    end
                  else
                    ''
                  end

        return "#{v}#{edition}-1.el6" if el6?
        return "#{v}#{edition}-1.el7.centos" if el7?
        return "#{v}#{edition}-1.50.amzn1" if amazon?
        return "#{v}#{edition}-1.fc#{node['platform_version'].to_i}" if fedora?
        return "#{v}#{edition}-0~#{precise_prefix}precise" if precise?
        return "#{v}#{edition}-0~#{node['platform']}" if debuntu?
        v
      end

      def default_docker_version
        return '1.7.1' if el6?
        return '17.03.1' if amazon?
        return '17.04.0' if precise?
        '17.06.0'
      end

      def default_package_name
        return 'docker' if amazon?
        return 'docker-engine' if el6?
        'docker-ce'
      end

      def docker_bin
        '/usr/bin/docker'
      end
    end
  end
end
