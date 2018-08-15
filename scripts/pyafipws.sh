#!/bin/bash

# PyAfipWs solo funciona con Python 2 :(

if [ ! -f /home/vagrant/.python2 ] ; then
    apt-get install -y python python-pip
    touch /home/vagrant/.python2
fi

if [ ! -f /home/vagrant/.pythondev ] ; then
    apt-get install -y python-dev
    touch /home/vagrant/.pythondev
fi

# Para compilar M2Crypto son necesarios swig y libssl-dev

if [ ! -f /home/vagrant/.swig ] ; then
	apt-get install -y swig
    touch /home/vagrant/.swig
fi

if [ ! -f /home/vagrant/.libssldev ] ; then
	apt-get install -y libssl-dev
    touch /home/vagrant/.libssldev
fi

# Entorno virtual para no "contaminar" el espacio global

if [ ! -f /home/vagrant/.virtualenv ] ; then
    apt-get install -y virtualenv
    touch /home/vagrant/.virtualenv
fi

folder="/home/vagrant/pyafipws"
env="/home/vagrant/pyafipenv"
user="vagrant"

if [ ! -d "$folder" ]; then
    git clone https://github.com/reingart/pyafipws.git $folder

    if [ -d "$folder" ]; then
        chown -R $user:$user "$folder"
        mkdir "${folder}/cache"
        chmod 775 "${folder}/cache"
        chown $user:www-data "${folder}/cache"
    else
        echo "No se pudo clonar el repositorio de PyAfipWS"
    fi
else
    echo "PyAfipWS ya se encuentra instalado"
fi

if [ ! -d "$env" ]; then
    virtualenv "$env" -p python

    if [ -d "$env" ]; then
        source "$env/bin/activate"
        pip install -r "${folder}/requirements.txt"
        pip install httplib2==0.9.2
        deactivate
        chown -R $user:$user "$env"
    else
        echo "No se pudo crear el entorno virtual $env"
    fi
else
    echo "Entorno $env ya se encuentra instalado"
fi
