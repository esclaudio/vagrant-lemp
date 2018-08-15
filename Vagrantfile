# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

Vagrant.require_version ">= 1.6.0"
VAGRANTFILE_API_VERSION = "2"

confDir = File.expand_path(File.dirname(__FILE__))

settings = YAML.load_file(confDir + '/settings.yaml')

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box = "bento/ubuntu-18.04"

    config.vm.provider :virtualbox do |vb|
        vb.memory = settings["memory"]
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
        vb.customize ["modifyvm", :id, "--usb", "off"]
        vb.customize ["modifyvm", :id, "--usbehci", "off"]
        vb.customize ["modifyvm", :id, "--uartmode1", "disconnected"]
        vb.customize ["modifyvm", :id, "--cableconnected1", "on"]
        vb.customize ["modifyvm", :id, "--ostype", "Ubuntu_64"]
    end

    # Private Network IP

    config.vm.network :private_network, ip: settings["ip"] ||= "192.168.10.10"

    # Additional Networks

    if settings.has_key?("networks")
        settings["networks"].each do |network|
            config.vm.network network["type"] + "_network", ip: network["ip"], bridge: network["bridge"] ||= nil
        end
    end

    # Folders

    if settings.has_key?("folders")
        settings["folders"].each do |folder|
            if folder.has_key?("nfs") && folder["nfs"]
                config.vm.synced_folder folder["map"], folder["to"], type: "nfs", mount_options: ['actimeo=1', 'nolock']
            else
                config.vm.synced_folder folder["map"], folder["to"], :owner => "vagrant", :group => "www-data", mount_options: ["dmode=775,fmode=775"]
            end
        end
    end

    # Provisions

    config.vm.provision :shell, :args => [settings['mysql_user'] ||= "vagrant"], path: "scripts/provision.sh"

    # Sites & Aliases

    if settings.has_key?("sites")
        settings["sites"].each do |site|
            if site.has_key?("aliases")
                aliases = "("
                site["aliases"].each do |a|
                    aliases += " [" + a["map"] + "]=" + a["to"]
                end
                aliases += " )"
            end
            config.vm.provision :shell, :args => [site["map"], site["to"], aliases ||= ""], path: "scripts/sites.sh"
        end

        config.vm.provision :shell, inline: "service nginx restart"
    end

    if settings.has_key?("databases")
        settings["databases"].each do |database|
            config.vm.provision :shell, :args => [database], path: "scripts/databases.sh"
        end
    end

    # PyAfipWS

    if settings.has_key?("pyafipws") && settings["pyafipws"]
        config.vm.provision :shell, path: "scripts/pyafipws.sh"
    end

    # Hosts Updater

    config.hostsupdater.aliases = settings["sites"].map { |site| site["map"] }
end
