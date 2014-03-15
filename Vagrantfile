# Base hostname
cookbook = 'docker'

# Environment variable information:
# http://docs.rackspace.com/servers/api/v2/cs-gettingstarted/content/gs_env_vars_summary.html 
# AWS region
if ENV['AWS_REGION']
  AWS_REGION = ENV['AWS_REGION']
elsif ENV['AWS_DEFAULT_REGION']
  AWS_REGION = ENV['AWS_DEFAULT_REGION']
elsif ENV['EC2_URL']
  AWS_REGION = ENV['EC2_URL'].gsub(/^http(s)?:\/\/ec2\./, '').gsub(/.amazonaws.com$/, '')
else
  AWS_REGION = 'us-west-2'
end
# Rackspace API key
RACKSPACE_API_KEY = ENV['RACKSPACE_API_KEY'] || ENV['OS_PASSWORD']
# Rackspace region
if ENV['RACKSPACE_REGION']
  RACKSPACE_REGION = ENV['RACKSPACE_REGION'].intern
elsif ENV['OS_REGION_NAME']
  RACKSPACE_REGION = ENV['OS_REGION_NAME'].downcase.intern
else
  RACKSPACE_REGION = :dfw
end
# Rackspace username
RACKSPACE_USERNAME = ENV['RACKSPACE_USERNAME'] || ENV['OS_USERNAME']
# SSH information
SSH_KEYPAIR = ENV['SSH_KEYPAIR']
SSH_PRIVATE_KEY_PATH = ENV['SSH_PRIVATE_KEY_PATH']
SSH_PUBLIC_KEY_PATH = ENV['SSH_PUBLIC_KEY_PATH']

Vagrant.configure('2') do |config|
  config.berkshelf.enabled = true
  config.cache.auto_detect = true
  config.omnibus.chef_version = :latest

  config.vm.define :centos5 do |centos5|
    centos5.vm.box      = 'opscode-centos-5.10'
    centos5.vm.box_url  = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-5.10_chef-provisionerless.box'
    centos5.vm.hostname = "#{cookbook}-centos-5"
  end

  config.vm.define :centos6 do |centos6|
    centos6.vm.box      = 'opscode-centos-6.5'
    centos6.vm.box_url  = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-6.5_chef-provisionerless.box'
    centos6.vm.hostname = "#{cookbook}-centos-6"
  end

  config.vm.define :debian7 do |debian7|
    debian7.vm.box      = 'opscode-debian-7.2.0'
    debian7.vm.box_url  = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_debian-7.2.0_chef-provisionerless.box'
    debian7.vm.hostname = "#{cookbook}-debian-7"
  end

  config.vm.define :fedora18 do |fedora18|
    fedora18.vm.box      = 'opscode-fedora-18'
    fedora18.vm.box_url  = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_fedora-18_chef-provisionerless.box'
    fedora18.vm.hostname = "#{cookbook}-fedora-18"
  end

  config.vm.define :fedora19 do |fedora19|
    fedora19.vm.box      = 'opscode-fedora-19'
    fedora19.vm.box_url  = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_fedora-19_chef-provisionerless.box'
    fedora19.vm.hostname = "#{cookbook}-fedora-19"
  end

  config.vm.define :fedora20 do |fedora20|
    fedora20.vm.box      = 'opscode-fedora-20'
    fedora20.vm.box_url  = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_fedora-20_chef-provisionerless.box'
    fedora20.vm.hostname = "#{cookbook}-fedora-20"
  end

  config.vm.define :freebsd9 do |freebsd9|
    freebsd9.vm.box      = 'opscode-freebsd-9.2'
    freebsd9.vm.box_url  = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_freebsd-9.2_chef-provisionerless.box'
    freebsd9.vm.hostname = "#{cookbook}-freebsd-9"
  end

  config.vm.define :ubuntu1204 do |ubuntu1204|
    ubuntu1204.vm.hostname = "#{cookbook}-ubuntu-1204"
    ubuntu1204.vm.provider 'aws' do |aws|
      aws.ami = 'ami-c8bed2f8'
      config.ssh.username = 'ubuntu'
    end
    ubuntu1204.vm.provider 'rackspace' do |rs|
      rs.image = /Ubuntu 12.04 LTS \(Precise Pangolin\) \(PVHVM\)/
      rs.server_name = "#{cookbook}-ubuntu-1204"
    end
    ubuntu1204.vm.provider 'virtualbox' do |vbox, override|
      override.vm.box = 'opscode-ubuntu-12.04'
      override.vm.box_url = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-12.04_chef-provisionerless.box'
    end
  end

  config.vm.define :ubuntu1210 do |ubuntu1210|
    ubuntu1210.vm.hostname = "#{cookbook}-ubuntu-1210"
    ubuntu1210.vm.provider 'aws' do |aws|
      aws.ami = 'ami-aec8a49e'
      config.ssh.username = 'ubuntu'
    end
    ubuntu1210.vm.provider 'rackspace' do |rs|
      rs.image = /Ubuntu 12.10 \(Quantal Quetzal\) \(PVHVM\)/
      rs.server_name = "#{cookbook}-ubuntu-1210"
    end
    ubuntu1210.vm.provider 'virtualbox' do |vbox, override|
      override.vm.box = 'opscode-ubuntu-12.10'
      override.vm.box_url = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-12.10_chef-provisionerless.box'
    end
  end

  config.vm.define :ubuntu1304 do |ubuntu1304|
    ubuntu1304.vm.box      = 'opscode-ubuntu-13.04'
    ubuntu1304.vm.box_url  = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-13.04_chef-provisionerless.box'
    ubuntu1304.vm.hostname = "#{cookbook}-ubuntu-1304"
  end

  config.vm.define :ubuntu1310 do |ubuntu1310|
    ubuntu1310.vm.hostname = "#{cookbook}-ubuntu-1310"
    ubuntu1310.vm.provider 'aws' do |aws|
      aws.ami = 'ami-7e64074e'
      config.ssh.username = 'ubuntu'
    end
    ubuntu1310.vm.provider 'rackspace' do |rs|
      rs.image = /Ubuntu 13.10 \(Saucy Salamander\) \(PVHVM\)/
      rs.server_name = "#{cookbook}-ubuntu-1310"
    end
    ubuntu1310.vm.provider 'virtualbox' do |vbox, override|
      override.vm.box = 'opscode-ubuntu-13.10'
      override.vm.box_url = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-13.10_chef-provisionerless.box'
    end
  end

  config.vm.network :private_network, ip: '192.168.50.10'

  config.vm.provider 'aws' do |aws, override|
    aws.region = AWS_REGION
    aws.keypair_name = SSH_KEYPAIR
    aws.instance_type = 't1.micro'
    aws.security_groups = 'default'
    config.vm.box = 'dummy'
    config.vm.box_url = 'https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box'
    override.ssh.private_key_path = SSH_PRIVATE_KEY_PATH
  end

  config.vm.provider 'rackspace' do |rs, override|
    config.vm.box = 'dummy'
    config.vm.box_url = 'https://github.com/mitchellh/vagrant-rackspace/raw/master/dummy.box'
    override.ssh.private_key_path = SSH_PRIVATE_KEY_PATH if SSH_PRIVATE_KEY_PATH
    rs.api_key = RACKSPACE_API_KEY
    rs.flavor = /1 GB Performance/
    rs.key_name = SSH_KEYPAIR if SSH_KEYPAIR
    rs.public_key_path = SSH_PUBLIC_KEY_PATH if SSH_PUBLIC_KEY_PATH
    rs.rackspace_region = RACKSPACE_REGION
    rs.username = RACKSPACE_USERNAME
  end

  config.vm.provider 'virtualbox' do |vbox|
    vbox.customize ['modifyvm', :id, '--memory', 1024]
  end

  config.vm.provision :chef_solo do |chef|
    chef.log_level = :debug
    chef.json = {

    }
    chef.run_list = [
      "recipe[#{cookbook}]"
    ]
  end
end
