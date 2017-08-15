#!/usr/bin/python

import sys


if len(sys.argv)!= 2:
	print "Usage:"
	print sys.argv[0]+" num_paths"
	sys.exit(0)

num_paths=int(sys.argv[1])
sum_bw = 0
rtts = []
for i in range(0,num_paths):
	bw_input = input("Please enter bandwidth(MegaBit) for path "+str(i+1)+" ==> ")
	sum_bw += int(bw_input)
	rtt_input = input("Please enter RTT(MS) for path "+str(i+1)+" ==> ")
	rtts.append(int(rtt_input))

max_rtt = max(rtts) 

BDP= (num_paths*sum_bw*1000000) * (max_rtt*.001)
BDP = float(BDP)/8
MPTCP_BDP= 2*BDP
print "Details:"
print "Total Bandwidth: ",sum_bw
print "RTT MAX: ",max_rtt
print "Number of paths/subflows: "+str(sys.argv[1])
print "BDP: %d bytes"%BDP
print "MPTCP BDP: %d bytes"%MPTCP_BDP
