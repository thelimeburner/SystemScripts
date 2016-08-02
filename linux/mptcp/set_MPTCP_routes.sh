#!/bin/bash


###Network details 
address1="10.0.1.4"
gateway1="10.0.1.1" 
subnet1="10.0.1.0/24"
device1="eth0"

address2="10.0.2.4"
gateway2="10.0.2.1" 
subnet2="10.0.2.0/24"
device2="eth1"

address3="10.0.3.4"
gateway3="10.0.3.1" 
subnet3="10.0.3.0/24"
device3="eth2"

address4="10.0.4.4"
gateway4="10.0.4.1" 
subnet4="10.0.4.0/24"
device4="eth3"


##This creates two different routing tables, that we use based on source-address
ip rule add from $address1 table 1
ip rule add from $address2 table 2
ip rule add from $address3 table 3
ip rule add from $address4 table 4

##Configure the two different routing tables
ip route add $subnet1 dev $device1 scope link table 1
ip route add default via $gateway1  dev $device1 table 1


ip route add $subnet2 dev $device2 scope link table 2
ip route add default via $gateway2 dev $device2 table 2

ip route add $subnet3 dev $device3 scope link table 3
ip route add default via $gateway3 dev $device3 table 3

ip route add $subnet4 dev $device4 scope link table 4
ip route add default via $gateway4 dev $device4 table 4


#default route for the selection process of normal internet-traffic
ip route add default scope global nexthop via $gateway1 dev $device1






#####OLD INFORMATION
##This creates two different routing tables, that we use based on source-address
#ip rule add from 10.0.1.1 table 1
#ip rule add from 172.23.0.1 table 2

##Configure the two different routing tables
#ip route add 10.0.0.0/8 dev ens6 scope link table 1
#ip route add default via 10.0.0.1 dev ens6 table 1


#ip route add 172.16.0.0/12 dev ens7 scope link table 2
#ip route add default via 172.16.0.1 dev ens7 table 2


#default route for the selection process of normal internet-traffic
#ip route add default scope global nexthop via 10.0.0.1 dev ens6


