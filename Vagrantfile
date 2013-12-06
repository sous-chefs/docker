# We'll mount the Chef::Config[:file_cache_path] so it persists between
# Vagrant VMs
host_cache_path = File.expand_path("../.cache", __FILE__)
guest_cache_path = "/tmp/vagrant-cache"

# ensure the cache path exists
FileUtils.mkdir(host_cache_path) unless File.exist?(host_cache_path)

Vagrant.configure("2") do |config|
  config.berkshelf.enabled = true
  config.cache.auto_detect = true
  config.omnibus.chef_version = :latest

  config.vm.define :centos5 do |centos6|
    centos6.vm.box      = 'opscode-centos-5.10'
    centos6.vm.box_url  = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-5.10_chef-provisionerless.box'
    centos6.vm.hostname = 'docker-centos-5'
  end

  config.vm.define :centos6 do |centos6|
    centos6.vm.box      = 'opscode-centos-6.5'
    centos6.vm.box_url  = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-6.5_chef-provisionerless.box'
    centos6.vm.hostname = 'docker-centos-6'
  end

  config.vm.define :debian7 do |debian7|
    debian7.vm.box      = 'opscode-debian-7.2.0'
    debian7.vm.box_url  = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_debian-7.2.0_chef-provisionerless.box'
    debian7.vm.hostname = 'docker-debian-7'
  end

  config.vm.define :fedora18 do |fedora18|
    fedora18.vm.box      = 'opscode-fedora-18'
    fedora18.vm.box_url  = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_fedora-18_chef-provisionerless.box'
    fedora18.vm.hostname = 'docker-fedora-18'
  end

  config.vm.define :fedora19 do |fedora19|
    fedora19.vm.box      = 'opscode-fedora-19'
    fedora19.vm.box_url  = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_fedora-19_chef-provisionerless.box'
    fedora19.vm.hostname = 'docker-fedora-19'
  end

  config.vm.define :fedora20 do |fedora20|
    fedora20.vm.box      = 'opscode-fedora-20'
    fedora20.vm.box_url  = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_fedora-20_chef-provisionerless.box'
    fedora20.vm.hostname = 'docker-fedora-20'
  end

  config.vm.define :freebsd9 do |freebsd9|
    freebsd9.vm.box      = 'opscode-freebsd-9.2'
    freebsd9.vm.box_url  = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_freebsd-9.2_chef-provisionerless.box'
    freebsd9.vm.hostname = 'docker-freebsd-9'
  end

  config.vm.define :ubuntu1204 do |ubuntu1204|
    ubuntu1204.vm.box      = 'opscode-ubuntu-12.04'
    ubuntu1204.vm.box_url  = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-12.04_chef-provisionerless.box'
    ubuntu1204.vm.hostname = 'docker-ubuntu-1204'
  end

  config.vm.define :ubuntu1210 do |ubuntu1210|
    ubuntu1210.vm.box      = 'opscode-ubuntu-12.10'
    ubuntu1210.vm.box_url  = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-12.10_chef-provisionerless.box'
    ubuntu1210.vm.hostname = 'docker-ubuntu-1210'
  end

  config.vm.define :ubuntu1304 do |ubuntu1304|
    ubuntu1304.vm.box      = 'opscode-ubuntu-13.04'
    ubuntu1304.vm.box_url  = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-13.04_chef-provisionerless.box'
    ubuntu1304.vm.hostname = 'docker-ubuntu-1304'
  end

  config.vm.define :ubuntu1310 do |ubuntu1310|
    ubuntu1310.vm.box      = 'opscode-ubuntu-13.10'
    ubuntu1310.vm.box_url  = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-13.10_chef-provisionerless.box'
    ubuntu1310.vm.hostname = 'docker-ubuntu-1310'
  end

  config.vm.network :private_network, ip: '192.168.50.10'

  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", 1024]
  end

  config.vm.provision :chef_solo do |chef|
    chef.provisioning_path = guest_cache_path
    chef.log_level         = :debug

    chef.json = {
      
    }

    chef.run_list = %w{
      recipe[docker]
    }
  end

  config.vm.synced_folder host_cache_path, guest_cache_path
end