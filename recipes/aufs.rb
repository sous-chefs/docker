case node['platform']
when 'ubuntu'
  #
  # The below code copied from: https://github.com/thoward/docker-cookbook/blob/master/recipes/default.rb
  # It's not pretty, but gets the job done!
  #
  # If aufs isn't available, do our best to install the correct
  # linux-image-extra package. This is somewhat messy because the
  # naming of these packages is very inconsistent across kernel
  # versions
  extra_package = Mixlib::ShellOut.new("apt-cache search linux-image-extra-`uname -r | grep --only-matching -e [0-9]\.[0-9]\.[0-9]-[0-9]*` | cut -d ' ' -f 1").run_command.stdout.strip
  unless extra_package.empty?
    package extra_package do
      not_if 'modprobe -l | grep aufs'
    end
  end

  modules 'aufs' do
    action :load
  end
end
