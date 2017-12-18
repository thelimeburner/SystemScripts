#!/bin/bash


/mptcp/./turn_off_interface.sh eno1
/mptcp/./turn_off_interface.sh eno2
/mptcp/./turn_off_interface.sh eno3
/mptcp/./turn_off_interface.sh eno4
/mptcp/./turn_off_interface.sh lxcbr0
/mptcp/./turn_off_interface.sh virbr0
/mptcp/./turn_off_interface.sh docker0

