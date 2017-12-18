#!/bin/bash

int_stat=$(/mptcp/check_interfaces.py)



record_send_window(){
	send_win=$(sudo sysctl net.ipv4.tcp_wmem | awk '{ print "Send Win Min,"$3"\nSend Win Def,"$4"\nSend Win Max,"$5 }')
	echo "$send_win"	
}

record_recv_window(){
	#recv_max=$(sudo sysctl net.ipv4.tcp_rmem | awk '{ print $5 }')
	#recv_min=$(sudo sysctl net.ipv4.tcp_rmem | awk '{ print $3 }')
	#recv__default=$(sudo sysctl net.ipv4.tcp_rmem | awk '{ print $4 }')
	#echo "Recv Win Min,$send_min" 
	#echo "Recv Win Def,$send_default" 
	#echo "Recv Win Max,$send_max" 
	recv_win=$(sudo sysctl net.ipv4.tcp_rmem | awk '{ print "Recv Win Min,"$3"\nRecv Win Def,"$4"\nRecv Win Max,"$5 }')
	echo "$recv_win"	

}

record_max_recv(){
	max_recv=$(sudo sysctl net.core.rmem_max | awk '{print "Max Core Recv,"$3}')
	echo "$max_recv"

}

record_max_send(){
	max_send=$(sudo sysctl net.core.wmem_max | awk '{print "Max Core Send,"$3}')
	echo "$max_send"

}

record_mod_recv(){
	mod_recv=$(sudo sysctl net.ipv4.tcp_moderate_rcvbuf | awk '{print "Auto Recieve Buffer Tuning,"$3}')
	echo "$mod_recv"

}

record_variable(){
	TAG=$2
	var=$(sudo sysctl $1 | awk -v tag="$TAG" '{print tag","$3}')
	#var=$(sudo sysctl $1 | awk -v tag="$TAG" 'BEGIN {print tag","$3}')
	echo "$var"
}
record_subflows(){
	ndiffports=$(cat /sys/module/mptcp_ndiffports/parameters/num_subflows)
	fullmesh=$(cat /sys/module/mptcp_fullmesh/parameters/num_subflows)
	echo "ndiffports flows,"$ndiffports
	echo "fullmesh flows,"$fullmesh

}

record_hostname(){
	hn=$(hostname)
	echo "hostname,"$hn
}

record_kernel(){
	k=$(uname -r)
	echo "kernel,"$k
}


record_hostname
echo "$int_stat"
record_send_window
record_recv_window
record_max_recv
record_max_send
record_mod_recv
record_variable net.mptcp.mptcp_enabled "MPTCP Enabled" 

record_variable net.mptcp.mptcp_checksum "MPTCP Checksum Enabled" 
record_variable net.mptcp.mptcp_debug "MPTCP Debug Enabled"
record_variable net.mptcp.mptcp_path_manager "MPTCP Path Manager"
record_variable net.mptcp.mptcp_scheduler "MPTCP Scheduler"
record_variable net.mptcp.mptcp_syn_retries "MPTCP SYN Retries"
record_variable net.mptcp.mptcp_version "MPTCP Version"
record_variable net.ipv4.tcp_congestion_control "CC Algo"
record_subflows
record_kernel

 
