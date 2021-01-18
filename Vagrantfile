# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
config.vm.define "elk" do |elk|
     elk.vm.box = "ubuntu/bionic64"
     elk.vm.box_check_update = false
     elk.vm.hostname = "elk"
     elk.vm.network "private_network", ip: "192.168.1.3", nic_type: "virtio", virtualbox__intnet: "elk_network"
     elk.vm.network "forwarded_port", guest: 5601, host: 1234
     elk.vm.provision "shell", path: "elk.sh"
     elk.vm.provider "virtualbox" do |vb|
       vb.memory = "3072"
       vb.customize ["modifyvm", :id, "--vram", "12"]
       vb.default_nic_type = "virtio"
     end
    end 

config.vm.define "app" do |app|
     app.vm.box = "ubuntu/bionic64"
     app.vm.box_check_update = false
     app.vm.hostname = "app"
     app.vm.network "private_network", ip: "192.168.1.2", nic_type: "virtio", virtualbox__intnet: "elk_network"
     app.vm.network "forwarded_port", guest: 80, host: 7000
     app.vm.provision "shell", path: "app.sh"
     app.vm.provider "virtualbox" do |vb|
       vb.memory = "1024"
       vb.customize ["modifyvm", :id, "--vram", "12"]
       vb.default_nic_type = "virtio"
    end
   end 

end
