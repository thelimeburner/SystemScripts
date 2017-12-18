#!/usr/bin/python


import os 
import subprocess
	
def get_interfaces():
	return os.listdir('/sys/class/net/')


#ip link show dev eno1

cmd = "sudo ip link show dev "


ints = get_interfaces()
for iface in ints:
	int_data = subprocess.check_output(['/sbin/ip', 'link','show','dev',iface])
	if "NOMULTIPATH" in int_data:
		print iface+", Multipath off"
	else:
		print iface+", Multipath on"
