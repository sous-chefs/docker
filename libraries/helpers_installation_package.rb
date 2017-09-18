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

      def debuntu?
        return true if node['platform_family'] == 'debian'
        false
      end

      def wheezy?
        return true if node['platform'] == 'debian' && node['platform_version'].to_i == 7
        false
      end

      def jessie?
        return true if node['platform'] == 'debian' && node['platform_version'].to_i == 8
        false
      end

      def stretch?
        return true if node['platform'] == 'debian' && node['platform_version'].to_i == 9
        false
      end

      def precise?
        return true if node['platform'] == 'ubuntu' && node['platform_version'] == '12.04'
        false
      end

      def trusty?
        return true if node['platform'] == 'ubuntu' && node['platform_version'] == '14.04'
        false
      end

      def xenial?
        return true if node['platform'] == 'ubuntu' && node['platform_version'] == '16.04'
        false
      end

      def zesty?
        return true if node['platform'] == 'ubuntu' && node['platform_version'] == '17.04'
        false
      end

      def amazon?
        return true if node['platform'] == 'amazon'
        false
      end

      # https://github.com/chef/chef/issues/4103
      def version_string(v)
        ubuntu_prefix = if Gem::Version.new(v) > Gem::Version.new('1.12.3')
                          'ubuntu'
                        else
                          ''
                        end

        debian_prefix = if Gem::Version.new(v) > Gem::Version.new('1.12.3')
                          'debian'
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

        codename = if Gem::Version.new(v) < Gem::Version.new('17.06.0')
                     if wheezy?
                       '-wheezy'
                     elsif jessie?
                       '-jessie'
                     elsif stretch?
                       '-stretch'
                     elsif precise?
                       '-precise'
                     elsif trusty?
                       '-trusty'
                     elsif xenial?
                       '-xenial'
                     elsif zesty?
                       '-zesty'
                     end
                   else
                     ''
                   end

        return "#{v}#{edition}-1.el6" if el6?
        return "#{v}#{edition}-1.el7.centos" if el7?
        return "#{v}#{edition}-1.59.amzn1" if amazon?
        return "#{v}#{edition}-1.fc#{node['platform_version'].to_i}" if fedora?
        return "#{v}#{edition}-0~#{debian_prefix}#{codename}" if node['platform'] == 'debian'
        return "#{v}#{edition}-0~#{ubuntu_prefix}#{codename}" if node['platform'] == 'ubuntu'
        v
      end

      def default_docker_version
        return '1.7.1' if el6?
        return '17.03.2' if amazon?
        return '17.04.0' if precise?
        '17.06.2'
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
