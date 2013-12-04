name              'docker'
maintainer        'Brian Flad'
maintainer_email  'bflad417@gmail.com'
license           'Apache 2.0'
description       'Installs/Configures Docker'
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           '0.19.1'
recipe            'docker', 'Installs/Configures Docker'
recipe            'docker::aufs', 'Installs/Loads AUFS Linux module'
recipe            'docker::binary', 'Installs Docker binary'
recipe            'docker::package', 'Installs Docker via package'
recipe            'docker::source', 'Installs Docker via source'
recipe            'docker::systemd', 'Installs/Starts Docker via systemd'
recipe            'docker::sysv', 'Installs/Starts Docker via SysV'
recipe            'docker::upstart', 'Installs/Starts Docker via Upstart'

%w{ centos fedora redhat ubuntu }.each do |os|
  supports os
end

%w{ apt git golang lxc modules yum }.each do |cb|
  depends cb
end
