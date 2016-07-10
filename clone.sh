#!/bin/bash
# ghost must delete /etc/udev/rules.d/70-persistent-net.rules

PATH=/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

set -x 

if [ $# -gt 4 ]
then
VM=$1
ip=$3
id=$2
br="br$id"
netmask=$4
gateway=$5
#mem=$6
#cpu=$7
#disk=$8
vm_sn=$9

mac=`echo $ip|awk -F'.' '{printf "f0:00:%.2x:%.2x:%.2x:%.2x",$1,$2,$3,$4}'`
uuid=`echo $ip|md5sum|awk '{print $1}'|sed 's/\(.\{8\}\)\(.\{4\}\)\(.\{4\}\)\(.\{4\}\)\(.\{12\}\)/\1-\2-\3-\4-\5/'`
if [ -z $6 ]
then
memory=$((15 * 1024 * 512 ))
else
memory=`echo "$6 * 1024 * 1024" | bc`
memory=`echo $memory | awk '{printf("%d\n",$1 + 0.5)}'`
fi
if [ -z $7 ]
then
cpu=4
else
cpu=$7
fi
if [ -z $8 ]
then
disk=80
else
disk=$8
fi

cp /export/image/image$disk.qcow2 /export/kvm/$VM.qcow2

if [ -e /etc/sysconfig/network-scripts/ifcfg-$br ]
then
 echo 
else
 bash /export/clone/mk_vlancfg.sh bond0 $id
 vms=`virsh list --name |grep -v '^$'|wc -l`
 if [ $vms == 0 ];then
  service network restart
 fi
fi

if [ -e /etc/sysconfig/network-scripts/ifcfg-bond0.$id ]
then
 ifup bond0.$id
fi

sed -e "/name/ s/test/$VM/" -e "/uuid/ s/13ef9ecc-3f87-43a7-349a-61c74cdcfa61/$uuid/" -e "/memory/ s/7864320/$memory/" -e "/currentMemory/ s/7864320/$memory/" -e "/vcpu/ s/4/$7/" -e "/mac address/ s/52:54:00:93:58:73/$mac/" -e "/source bridge/ s/br0/$br/" -e "/source file/ s/test.qcow2/$VM.qcow2/" -e "s/11111111/$vm_sn/" /export/clone/gho.xml > /etc/libvirt/qemu/$VM.xml

virsh define /etc/libvirt/qemu/$VM.xml

sed -e "s/IP_ADDRESS_GOES_HERE/$ip/g" -e "s/VM_NAME_GOES_HERE/$VM/g" -e "s/NETMASK_GOES_HERE/$netmask/g" -e "s/GATEWAY_GOES_HERE/$gateway/g"< /export/clone/configure.sh > /export/clone/logs/configure.sh.$VM


chmod a+x /export/clone/logs/configure.sh.$VM
virt-sysprep -d $VM \
  --enable udev-persistent-net,script,bash-history,hostname,logfiles,utmp,script \
  --hostname $VM \
  --script /export/clone/logs/configure.sh.$VM  > /dev/null
virsh start $VM
virsh autostart $VM
else
	echo "Usage: $0 <Hostname> <vlanID> <IP> <Netmask> <Gateway> <Memory Size> <N CPUs> <Disk size> <vm_sn>"
	echo "		Notice: Hostname must be full qualitified DNS name (FQDN). If vlanID is not supported by network"
	echo "		environment, use 0 (zero) as vlanID. Disk size only have choice of 80G or 160G. Please carefully"
	echo "		calculate the CPU and memory usage of the host. "
	echo "		Recommend configuration are (calculate for 64G memory on host, 8 guests per host):"
	echo "		Memory Size: 	7.5"
	echo "		N CPUs:		4"
	echo "		Disk Size:	80 or 160" 
exit 0
fi
