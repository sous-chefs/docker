module DockerCookbook
  module DockerHelpers
    module InstallationPackage
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

      def jessie?
        return true if node['platform'] == 'debian' && node['platform_version'].to_i == 8
        false
      end

      def stretch?
        return true if node['platform'] == 'debian' && node['platform_version'].to_i == 9
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

      def artful?
        return true if node['platform'] == 'ubuntu' && node['platform_version'] == '17.10'
        false
      end

      def amazon?
        return true if node['platform'] == 'amazon'
        false
      end

      # https://github.com/chef/chef/issues/4103
      def version_string(v)
        edition =  if debuntu?
                     '~ce'
                   elsif amazon?
                     'ce'
                   else
                     '.ce'
                   end

        codename = if Gem::Version.new(v) < Gem::Version.new('17.06.0')
                     if jessie?
                       '-jessie'
                     elsif stretch?
                       '-stretch'
                     elsif trusty?
                       '-trusty'
                     elsif xenial?
                       '-xenial'
                     elsif zesty?
                       '-zesty'
                     elsif artful?
                       '-artful'
                     end
                   else
                     ''
                   end

        return "#{v}#{edition}-1.el7.centos" if el7?
        return "#{v}#{edition}-1.111.amzn1" if amazon?
        return "#{v}#{edition}" if fedora?
        return "#{v}#{edition}-0~debian#{codename}" if node['platform'] == 'debian'
        return "#{v}#{edition}-0~ubuntu#{codename}" if node['platform'] == 'ubuntu'
        v
      end

      def default_docker_version
        return '17.09.1' if amazon?
        '17.12.0'
      end

      def default_package_name
        return 'docker' if amazon?
        'docker-ce'
      end

      def docker_bin
        '/usr/bin/docker'
      end
    end
  end
end
