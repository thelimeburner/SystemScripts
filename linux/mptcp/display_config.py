#!/usr/bin/python


import subprocess
from prettytable import PrettyTable


lines = subprocess.check_output(['/mptcp/./record_config.sh']).split("\n")
lines = lines[:-1]
config = PrettyTable(['Config Variable', 'Value'])

for line in lines:
	parts = line.split(",")

	config.add_row(parts)


print config
