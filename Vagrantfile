# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

VAGRANTFILE_API_VERSION ||= "2"

confDir = confDir ||= File.expand_path(File.dirname(__FILE__))
settings = YAML.load_file(confDir + '/settings.yaml')

Vagrant.require_version ">= 2.1.0"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box = "debian/bullseye64"

    config.vm.provider :virtualbox do |vb|
        vb.memory = settings["memory"]
        vb.cpus = settings["cpus"]

        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
        vb.customize ["modifyvm", :id, "--usb", "off"]
        vb.customize ["modifyvm", :id, "--usbehci", "off"]
        vb.customize ["modifyvm", :id, "--uartmode1", "disconnected"]
        vb.customize ["modifyvm", :id, "--cableconnected1", "on"]
        vb.customize ["modifyvm", :id, "--ostype", "Debian_64"]
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
            config.vm.synced_folder folder["map"], folder["to"], type: "nfs", :nfs_version => 4, nfs_udp: false
        end
    end

    # Provisions

    config.vm.provision :shell, path: "scripts/provision.sh"

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

    # Hosts Updater

    config.hostsupdater.aliases = settings["sites"].map { |site| site["map"] }
end
