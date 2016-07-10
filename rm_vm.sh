#!/bin/bash

PATH=/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

name=$1

virsh destroy  $1
virsh undefine $1

rm -f /export/clone/configure.sh.$1

rm -f /export/kvm/$1.qcow2
