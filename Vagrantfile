# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
require "yaml"
params = YAML::load_file("./config.yml");


Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "dummy"
  # config.vm.hostname = params['hostname']


  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"
  # config.vm.network "public_network", ip: params['ip']

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider :aws do |aws, override|
    # Display the VirtualBox GUI when booting the machine
    # vb.gui = false

    # Customize the amount of memory on the VM:
    # vb.memory = "3072"
    # vb.cpus = 2
    # file_to_disk = params['file_to_disk']
    #
    # if ARGV[0] == "up" && !File.exist?(file_to_disk)
    #     vb.customize ['createhd',
    #           '--filename', file_to_disk,
    #           '--format', 'VDI',
    #           '--size', params['disk_size_GB'] * 1024 # 500GB
    #           ]
    # end
    # vb.customize [
    #     'storageattach', :id,
    #     '--storagectl', 'SATAController',
    #     '--port', 1, '--device', 0,
    #     '--type', 'hdd', '--medium',
    #     file_to_disk
    #     ]
    aws.elastic_ip = params['AWS_ELASTIC_IP']
    aws.access_key_id = params['AWS_ACCESS_KEY_ID']
    aws.secret_access_key = params['AWS_SECRET_ACCESS_KEY']
    aws.keypair_name = params['AWS_KEYPAIR_NAME']

    aws.region = params['AWS_REGION']
    aws.instance_type = params['AWS_INSTANCE_TYPE']
    aws.block_device_mapping = [{ 'DeviceName' => '/dev/sda1', 'Ebs.VolumeSize' => 20 }, { 'DeviceName' => '/dev/sdb', 'Ebs.VolumeSize' => 500 }]
    aws.ami = "ami-5dd8b73a"
    override.ssh.username = "ubuntu"
    override.ssh.private_key_path = params['AWS_PRIVATE_KEY_PATH']
  end

  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell" do |s|
    s.path= "diskpartition.sh"
  end

  # Backup files and gitlab-ci artifacts will be located in /var/opt,
  # Make sure you have enough space
  config.vm.provision "shell",
    run: "always",
    inline: "sudo mount -t ext4 /dev/xvdb /var/opt"

  config.vm.provision "shell" do |s|
    s.path = "provision.sh"
    s.args = [params['AWS_ELASTIC_IP'], params['HOSTNAME']]
  end
end
