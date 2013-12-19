case node['platform']
when 'ubuntu'
  # If aufs isn't available, do our best to install the correct linux-image-extra package.
  uname = Mixlib::ShellOut.new('uname -r').run_command.stdout.strip
  extra_package = 'linux-image-extra-' + uname
  unless extra_package.empty?
    package extra_package do
      not_if 'modprobe -l | grep aufs'
    end
  end

  modules 'aufs' do
    action :load
  end
end
