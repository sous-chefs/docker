case node['platform']
when 'ubuntu'
  # If aufs isn't available, do our best to install the correct linux-image-extra package.
  # Use kernel release for saucy and newer, otherwise use older, more compatible regexp match
  if Chef::Version.new(node['platform_version']) < Chef::Version.new('13.10')
    # Original method copied from https://github.com/thoward/docker-cookbook/blob/master/recipes/default.rb
    package_name = 'linux-image-extra-' + Mixlib::ShellOut.new("uname -r | grep --only-matching -e [0-9]\.[0-9]\.[0-9]-[0-9]*").run_command.stdout.strip
  else
    # In modern ubuntu versions, kernel release matches the kernel package name
    package_name = 'linux-image-extra-' + node['kernel']['release']
  end

  extra_package = Mixlib::ShellOut.new('apt-cache search ' + package_name).run_command.stdout.split(' ').first
  # Wait to strip until after checking for empty, to protect against nil errors
  unless extra_package.nil? || extra_package.empty?
    package extra_package.strip do
      not_if 'modprobe -l | grep aufs'
    end
  end

  modules 'aufs' do
    action :load
  end
end
