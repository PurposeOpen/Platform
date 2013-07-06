# -*- mode: ruby -*-
# vi: set ft=ruby :


# Setup a simple Vagrant environment for Platform *development*
#
# To use:
#   Install VirtualBox and vagrant (vagrantup.com). 
#   - Tested with vagrant 1.1.5 and VB 4.2.10
#   vagrant up  (...wait while stuff happens...)
#   vagrant ssh
#   cd /platform
#   foreman start -f Platform.dev
#   Visit localhost:5000 in your web browser.
#
# If you want custom configuration in your .env, create a file called
# env.local with that configuration. It will be merged into the
# default configuration.
#
# Troubleshooting:
# Sometimes the gem / bundler steps fail to run. If this happens just
# run them manually. The trace will tell you which line failed. In
# most cases this will do:
#
#   vagrant ssh
#   cd /platform
#   bundle
#
# This setup installs all dependencies and then shares the current
# directory (containing the Platform code) on the host as /platform on
# the guest VM. Thus you can edit code as normal and changes will be
# instantly available to the VM. It also forward port 5000 from the
# guest to the host, so you can view pages in your usual web browser.
#
# Note there is no security etc. so this environment is not suitable
# for deployment.
#
# The environment is intended to Heroku-esque, but I haven't made any
# effort to exactly mirror the setup on Heroku.
Vagrant.configure("2") do |config|
  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "heroku-base"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "https://github.com/downloads/jochu/vagrant-heroku-base/heroku-base.box"

  # Forward a port from the guest to the host, which allows for outside
  # computers to access the VM, whereas host only networking does not.
  config.vm.network :forwarded_port, guest: 5000, host: 5000

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  config.vm.synced_folder ".", "/platform"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  config.vm.provider :virtualbox do |vb|
    # Don't boot with headless mode
    # vb.gui = true
    
    # Use more memory, for a bit of a performance boost
    vb.customize ["modifyvm", :id, "--memory", "1024"]

    # This might improve network performance
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]
    vb.customize ["modifyvm", :id, "--nictype1", "82540EM"]
  end

  # Enable provisioning with chef solo, specifying a cookbooks path, roles
  # path, and data_bags path (all relative to this Vagrantfile), and adding
  # some recipes and/or roles.
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = "chef/cookbooks"
    chef.add_recipe "recipe[apt]"
    chef.add_recipe "recipe[java]"
    chef.add_recipe "recipe[purpose]"
    chef.add_recipe "recipe[redis]"
  end
end
