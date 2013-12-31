case node['platform']
when 'ubuntu'
  # Verify the package exists before we attempt to install it
  extra_package = Mixlib::ShellOut.new('apt-cache search linux-image-extra-' + node['kernel']['release']).run_command.stdout.split(' ').first.strip
  unless extra_package.empty?
    package extra_package do
      not_if 'modprobe -l | grep -q aufs'
    end
  end

  modules 'aufs' do
    action :load
  end
end
