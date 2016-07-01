#!/bin/bash


###Network details 
address1="10.0.1.1"
gateway1="10.0.0.1" 
subnet1="10.0.0.0/8"
device1="ens6"

address2="172.23.0.1"
gateway2="172.16.0.1"
subnet2="172.16.0.0/12"
device2="ens7"



##This creates two different routing tables, that we use based on source-address
ip rule add from $address1 table 1
ip rule add from $address2 table 2

##Configure the two different routing tables
ip route add $subnet1 dev $device1 scope link table 1
ip route add default via $gateway1  dev $device1 table 1


ip route add $subnet2 dev $device2 scope link table 2
ip route add default via $gateway2 dev $device2 table 2


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


