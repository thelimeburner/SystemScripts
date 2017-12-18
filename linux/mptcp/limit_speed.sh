#!/bin/bash


dev1=enp5s0f0
dev2=enp5s0f1

speed=$1

#Clear Settings
tc qdisc del root dev $dev1

# connection settings
tc qdisc add dev $dev1 root handle  10:   htb default 2

#Set Rate
tc class add dev $dev1 parent 10:  classid 10:1  htb rate $speed





####DEVICE 2 
#Clear Settings
tc qdisc del root dev $dev2

# connection settings
tc qdisc add dev $dev2 root handle  10:   htb default 2

#Set Rate
tc class add dev $dev2 parent 10:  classid 10:2  htb rate $speed



###Enable for cgroups
tc filter add dev $dev1 parent 10:  handle   1:   protocol all cgroup
tc filter add dev $dev2 parent 10:  handle   2:   protocol all cgroup


mkdir -p /sys/fs/cgroup/net_cls/experiment

echo 0x00100002 >  /sys/fs/cgroup/net_cls/experiment/net_cls.classid
echo 0x00100001 >  /sys/fs/cgroup/net_cls/experiment/net_cls.classid
