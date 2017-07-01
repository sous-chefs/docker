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

      def wheezy?
        return true if node['platform'] == 'debian' && node['platform_version'].to_i == 7
        false
      end

      def jesse?
        return true if node['platform'] == 'debian' && node['platform_version'].to_i == 8
        false
      end

      def precise?
        return true if node['platform'] == 'ubuntu' && node['platform_version'] == '12.04'
        false
      end

      def trusty?
        return true if node['platform'] == 'ubuntu' && node['platform_version'] == '14.04'
        return true if node['platform'] == 'linuxmint' && node['platform_version'] =~ /^17\.[0-9]$/
        false
      end

      def vivid?
        return true if node['platform'] == 'ubuntu' && node['platform_version'] == '15.04'
        false
      end

      def wily?
        return true if node['platform'] == 'ubuntu' && node['platform_version'] == '15.10'
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

      def debuntu?
        return true if node['platform_family'] == 'debian'
        return true if node['platform_family'] == 'ubuntu'
        false
      end

      # https://github.com/chef/chef/issues/4103
      def version_string(v)
        ubuntu_prefix = if Gem::Version.new(v) > Gem::Version.new('1.12.3')
                          'ubuntu-'
                        else
                          ''
                        end

        debian_prefix = if Gem::Version.new(v) > Gem::Version.new('1.12.3')
                          'debian-'
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
        return "#{v}#{edition}-0~#{debian_prefix}wheezy" if wheezy?
        return "#{v}#{edition}-0~#{debian_prefix}jessie" if jesse?
        return "#{v}#{edition}-0~#{ubuntu_prefix}precise" if precise?
        return "#{v}#{edition}-0~#{ubuntu_prefix}trusty" if trusty?
        return "#{v}#{edition}-0~#{ubuntu_prefix}vivid" if vivid?
        return "#{v}#{edition}-0~#{ubuntu_prefix}wily" if wily?
        return "#{v}#{edition}-0~#{ubuntu_prefix}xenial" if xenial?
        return "#{v}#{edition}-0~#{ubuntu_prefix}zesty" if zesty?
        v
      end

      def default_docker_version
        return '1.7.1' if el6?
        return '1.9.1' if vivid?
        return '17.03.1' if amazon?
        return '17.04.0' if precise?
        '17.05.0'
      end

      def default_package_name
        return 'docker' if amazon?
        'docker-engine'
      end

      def docker_bin
        '/usr/bin/docker'
      end
    end
  end
end
