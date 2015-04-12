#!/bin/bash

TAP="tap0"
BRIDGE="br0"
ETHLINK="eth0"

if test "`whoami`" != "root"; then
	echo "Must be run as root sorry" >&2
	exit 1
fi

echo "This script assumes a large amount about your machine network configuration. Type 'yes' to acknowledge you're probably about to be knocked off your internet connection. Read source for assumptions."
read line
if test "$line" != "yes"; then
	echo "It was a trap anyway" >&2
	exit 1
fi

# Those assumptions:
#  - You have a wired connection. It seems increadibly unlikely that this will
#    ever work wirelessly unless you're one with wpa_supplicant,
#  - That wired connection is eth0
#  - There's dhcp on it that this script can just dhclient at
#  - Your network connection doesn't used one of the following ranges:
#     - 192.168.33/24
#     - 192.168.34/24
#     - 192.168.35/24
#     - 10.1/16
#     - 10.2/16
#     - 10.3/16
#     - 10.4/16

# Test for the presence of VDE

which vde_switch > /dev/null 2>&1
if test $? != 0; then
	echo "You need to install vde / vde2 for virtual network mangling to work" >&2
	exit 1
fi

mkdir /tmp/srnet 2>/dev/null
if test -e /tmp/srnet/newbury; then
	echo "Looks like the virtual network already exists!"
	exit 1
fi

echo "You should now turn off network manager. (For a calmer lifestyle, disable it). Hit enter once done"
read line

# Here we go

# Print commands as we go
set -v
set -x

# Create a tunnel interface
ip tuntap add dev $TAP mode tap

# Create bridge
ip link add $BRIDGE type bridge

# Wipe wired config
ip addr flush dev $ETHLINK

# Hook up bridged links
ip link set $TAP master $BRIDGE
ip link set $ETHLINK master $BRIDGE

# Bring eth / bridge links up
ip link set $BRIDGE up
ip link set $ETHLINK up

# Try to get an address on the bridge now, for this machines internet
echo "Getting an address on $BRIDGE"
dhclient $BRIDGE

if test $? != 0; then
	echo "dhclient failed; internet is now your problem"
fi

# Bring up tap,
ip link set $TAP up

function do_network {
	# Connect vswitch in
	vde_switch -s /tmp/srnet/newbury -tap tap0 -m 666 &

	# Generate switches for the 3 floor networks
	# Don't put them on tap, they're not connected directly to the net
	vde_switch -s /tmp/srnet/floor0 -m 666 &
	vde_switch -s /tmp/srnet/floor1 -m 666 &
	vde_switch -s /tmp/srnet/floor2 -m 666
}

function cleanup {
	echo "itsatrap"

	# Kill all jobs
	kill %1
	kill %2
	kill %3
	kill %4

	# Take tap down
	ip link set $TAP down

	# Remove from bridge
	ip link set $TAP nomaster

	# Delete it
	ip link del $TAP

	# Take down bridge
	ip addr flush $BRIDGE
	ip link set $BRIDGE down

	# Also the ethernet l ink
	ip link set $ETHLINK down

	# Unhook bridge
	ip link set $ETHLINK nomaster

	# Delete bridge
	ip link del $BRIDGE

	# Bring etherlink back up
	ip link set $ETHLINK up

	# And attempt to get an address
	echo "Trying to get an address back on $ETHLINK"
	dhclient $ETHLINK

	echo "All done; have a pleasent day"
}

# Tell the user what's going to happen
echo "Starting virtual switches; hit ctrl-c to nix all switches and undo some of the bridging. I'll dhclient $ETHLINK on exit, if/when that fails the internet is your problem again"

trap cleanup SIGINT SIGTERM SIGHUP

do_network
