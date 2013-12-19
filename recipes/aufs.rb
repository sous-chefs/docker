case node['platform']
when 'ubuntu'
  # If aufs isn't available, do our best to install the correct linux-image-extra package.
  if node['docker']['aufs']['legacy_package_finder']
    # Original method copied from https://github.com/thoward/docker-cookbook/blob/master/recipes/default.rb
    extra_package = Mixlib::ShellOut.new("apt-cache search linux-image-extra-`uname -r | grep --only-matching -e [0-9]\.[0-9]\.[0-9]-[0-9]*` | cut -d ' ' -f 1").run_command.stdout.strip
  else
    # In modern ubuntu versions, uname -r matches the kernel package name
    uname = Mixlib::ShellOut.new('uname -r').run_command.stdout.strip
    extra_package = 'linux-image-extra-' + uname
  end

  unless extra_package.empty?
    package extra_package do
      not_if 'modprobe -l | grep aufs'
    end
  end

  modules 'aufs' do
    action :load
  end
end
