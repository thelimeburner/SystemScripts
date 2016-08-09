#!/bin/bash


if sysctl net.mptcp.mptcp_enabled | grep 1; then
    echo "Turning off mptcp"
    sudo sysctl -w net.mptcp.mptcp_enabled=0
    sudo sysctl -w net.ipv4.tcp_congestion_control="reno" 
else
    echo "Turning on mptcp"
    sudo sysctl -w net.mptcp.mptcp_enabled=1
    sudo sysctl -w net.ipv4.tcp_congestion_control="lia" 
fi
