#!/bin/bash

if [ $# -ne 2 ]
then
   echo -e "please input \$1 \$2.\n\"sample like  mk_vlan.sh  bond0 143\".\n\$1 is netcard and \$2 is vlan id."
   exit 0
else 

device=$1

vlanid=$2


interface=$device.$vlanid

bridge=br$vlanid

modprobe 8021q

vconfig set_name_type  DEV_PLUS_VID_NO_PAD 

vconfig add $device  $vlanid

ifconfig $interface up

brctl addbr $bridge 

brctl setfd $bridge 0

brctl stp $bridge off

brctl addif $bridge $interface

ifconfig $bridge up

if [ -e /etc/sysconfig/network-scripts/ifcfg-$bridge ];then
    echo
else
    touch /etc/sysconfig/network-scripts/ifcfg-$bridge
fi
if [ -e /etc/sysconfig/network-scripts/ifcfg-$interface ];then
    cat /etc/sysconfig/network-scripts/ifcfg-$interface |egrep "IPADDR|NETMASK" > /tmp/local_ip
else
    touch /etc/sysconfig/network-scripts/ifcfg-$interface
fi

cat > /etc/sysconfig/network-scripts/ifcfg-$bridge << OOF
TYPE=Bridge
ONBOOT=yes
BOOTPROTO=static
NM_CONTROLLED=no
DELAY=0
OOF

echo "DEVICE=$bridge" >>  /etc/sysconfig/network-scripts/ifcfg-$bridge

cat >/etc/sysconfig/network-scripts/ifcfg-$interface << GOF
BOOTPROTO=none
NM_CONTROLLED=no
ONBOOT=yes
TYPE=Ethernet
VLAN=yes
ONPARENT=yes
GOF
echo "DEVICE=$interface" >> /etc/sysconfig/network-scripts/ifcfg-$interface
echo "BRIDGE=$bridge" >> /etc/sysconfig/network-scripts/ifcfg-$interface
[ -e /tmp/local_ip ] && cat /tmp/local_ip >> /etc/sysconfig/network-scripts/ifcfg-$interface

    if [[ -f /etc/sysconfig/network-scripts/ifcfg-$interface  && -f /etc/sysconfig/network-scripts/ifcfg-$bridge ]]
    then
        echo "$interface and $bridge config sucessful"
    else
        echo "configure faild"
    fi

trap - EXIT

exit 0

fi
