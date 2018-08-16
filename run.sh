#!/bin/sh
vagrant box remove test
rm *.box
packer build -only=virtualbox-iso ubuntu-16.04-amd64.json
#packer build -only=vmware-iso ubuntu-16.04-amd64.json
rm Vagrantfile
vagrant init test ./ubuntu-16.04-amd64-virtualbox.box
vagrant up
vagrant ssh
