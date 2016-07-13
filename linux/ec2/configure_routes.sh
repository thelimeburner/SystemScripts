#!/bin/bash

gateway=172.31.16.1
ip1=172.31.23.66
ip2=172.31.20.70




ip route add default via $gateway dev eth0 tab 1
ip rule add from $ip1 tab 1




ip route add default via $gateway dev eth1 tab 2
ip rule add from $ip2 tab 2
