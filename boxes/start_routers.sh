#!/bin/bash

which vagrant > /dev/null 2>&1
if test $? != 0; then
	echo "You must have vagrant installed" >&2
	exit 1
fi

trap "kill -9 0" SIGINT SIGTERM SIGHUP

# `vagrant box list` doesn't work for me. Test directly.
if test ! -d ~/.vagrant.d/boxes/chef/fedora-20; then
	echo "Downloading f20 box"
	vagrant box add chef/fedora-20 https://vagrantcloud.com/chef/boxes/fedora-20/versions/1.0.0/providers/virtualbox.box
else
	echo "Already have f20 base box"
fi

cwd=`pwd`

cd fruitcake
vagrant up
cd $cwd

cd nutter
vagrant up
cd $cwd

cd looney
vagrant up
cd $cwd
