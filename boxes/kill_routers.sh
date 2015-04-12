#!/bin/bash

cwd=`pwd`

cd fruitcake
vagrant halt -f
cd $cwd

cd looney
vagrant halt -f
cd $cwd

cd nutter
vagrant halt -f
cd $cwd
