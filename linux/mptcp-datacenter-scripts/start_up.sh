#!/bin/bash


#/scripts/./bring_up_networking.sh

/scripts/./turn_off_interfaces.sh

sudo /mptcp/./set_MPTCP_routes.sh

/mptcp/./validate.py -f /mptcp/mptcp_no_buffer
/mptcp/./validate.py -f /mptcp/tcp_no_buffer

/mptcp/./check_mptcp
