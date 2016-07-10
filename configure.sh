#!/bin/bash
# Run in the host, with the cwd being the root of the guest

set -x

# re-generate the keys. Letting virt-sysprep remove the keys
# is insufficient, and they don't get automatically regenerated
# on boot by Ubuntu. A dpkg-reconfigure fails for some reason,
# and doing a boot-time script is overkill, so just do it now explicitly.
#rm etc/ssh/ssh_host_rsa_key etc/ssh/ssh_host_rsa_key.pub
#rm etc/ssh/ssh_host_dsa_key etc/ssh/ssh_host_dsa_key.pub
#ssh-keygen  -N '' -t rsa -f etc/ssh/ssh_host_rsa_key
#ssh-keygen  -N '' -t dsa -f etc/ssh/ssh_host_dsa_key

echo "127.0.0.1   localhost localhost.localdomain" > etc/hosts
echo "IP_ADDRESS_GOES_HERE   VM_NAME_GOES_HERE" >> etc/hosts

echo "DEVICE=eth0" > etc/sysconfig/network-scripts/ifcfg-eth0
echo "BOOTPROTO=static" >> etc/sysconfig/network-scripts/ifcfg-eth0
echo "IPADDR=IP_ADDRESS_GOES_HERE" >> etc/sysconfig/network-scripts/ifcfg-eth0
echo "NETMASK=NETMASK_GOES_HERE" >> etc/sysconfig/network-scripts/ifcfg-eth0
echo "NM_CONTROLLED=yes" >> etc/sysconfig/network-scripts/ifcfg-eth0
echo "ONBOOT=yes" >> etc/sysconfig/network-scripts/ifcfg-eth0
echo "TYPE=Ethernet" >> etc/sysconfig/network-scripts/ifcfg-eth0
echo "GATEWAY=GATEWAY_GOES_HERE" >> etc/sysconfig/network-scripts/ifcfg-eth0
echo "id: IP_ADDRESS_GOES_HERE" >> etc/salt/minion
sed -i "s/GATEWAY.*/GATEWAY=GATEWAY_GOES_HERE/g" etc/sysconfig/network
#sa user keys
mkdir home/sa/.ssh/
chown sa.sa home/sa/.ssh/
chmod 700 home/sa/.ssh/
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAsahEpU5gVWcAYKka+MCNDYPy+eAs+EzjGgziM7EubPKIZjqwx3mdnrXboq1Hm8hU0wr/tYsV80E4PsWMKmAWWlO3UXCwLLwBECw/a6BcfAExKL6qj5UVpxBBVKLCUQZ5gZ+F8agBNud34p15s08/ZBY3dKQItODU2fG4yVVwlQ6ho91ZD/3k+3X0tfz2XnxD+f+AGpuOEKsz2BM8X+3FD6Nc3SE7Ov5tdYAIKVxLaGQPCSLGVKuBdnr7p9OHsy5ttJqMXXWciNoQ8veOg+jnH4ljZ8Rv0jClmd1zGBWDJSrZpC28jmfICt/vpJWo0D+0n24lR0lcsFgDZ4rQ92yWrw== root@JXQ-23-58-4.h.chinabank.com.cn" >> home/sa/.ssh/authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAuYXi/YWpgiSHUNFP15f5dQXtZcTOuamxfE1QRxrkn6PO/EI7X8zQprzIzwdfAEgUR1ePXNmuNjLgY0JINyD4r08tZiAGTG+iCm4SpP3DhsWfKZb79T6alvUXHcusaL6k/U76DR1W72LO2YLugzGlKWEbhfr9bGOQi7wIXMR40i8zzP+aJXXbXy0XkNWWFw6QQYtRAxuXApUV67PdwkRvddCj8evxdpXGkkr5QqVlkbz+nw5dtkZ8T20LofROMBLAX39u6TgP7MVyMsCut6r+FZugtbxy3VLqcKs2zhRrRGiV8SHI/g9rEn4wd4EBdWPEBafyUfEBQ9WIq2u9w1gLzw== root@JXQ-23-58-5.h.chinabank.com.cn" >> home/sa/.ssh/authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA629reRocBd45+HPdcJDcH6l2cTGohziRSZAybEvcU9EZBtS7j5YtS+8542oUTCPnuGkb2ktGVNMqt9XMWdi9FcJuqJzPUIcrzLgZscrE2Ih8t7OcCYfH4IuTi5fMQudRQSmoYTBuIpOIq3D7ZnsWWU5C9bXMAAbtpjfKRPsN8/+sCUffxvXbRgOlH5GTFTjQZluBv8ndjMhPHGLZGV+qiJnFFI1E8HDk4NGCeqin0jKvoTZQ5NWGwSKfJP7MvF2L5rAyPR7FgLpVfQcFb/n3LuNrzc495QblUiA5ZTE5siijZTztkArrd++kYBT8dxtZKLxNh6lWC5qWO8VacNYMjQ== root@HC-25-8-27.h.chinabank.com.cn" >> home/sa/.ssh/authorized_keys
chmod 600 home/sa/.ssh/authorized_keys
chown sa.sa home/sa/.ssh/authorized_keys
cp -p /tmp/vminit_*.conf tmp/
cp /root/dhcpserver root/
cp /export/clone/logs/systeminit.sh tmp/
echo "bash -x /tmp/systeminit.sh >/tmp/systeminit.log 2>&1" >> etc/rc.d/rc.local
rm -f etc/salt/pki/minion/minion.pem 
rm -f etc/salt/pki/minion/minion.pub
rm -f etc/salt/pki/minion/minion_master.pub 
