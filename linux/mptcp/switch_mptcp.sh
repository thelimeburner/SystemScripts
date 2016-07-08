#!/bin/bash


if sysctl net.mptcp.mptcp_enabled | grep 1; then
    echo "Turning off mptcp"
    sysctl -w net.mptcp.mptcp_enabled=0
else
    echo "Turning on mptcp"
    sysctl -w net.mptcp.mptcp_enabled=1
fi
