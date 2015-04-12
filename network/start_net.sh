#!/bin/bash

if test "`whoami`" != "root"; then
	echo "Must be run as root sorry" >&2
	exit 1
fi

echo "This script assumes a large amount about your machine network configuration. Type 'yes' to acknowledge you're probably about to be knocked off your internet connection"
read line
if test "$line" != "yes"; then
	echo "It was a trap anyway" >&2
	exit 1
fi
