from subprocess import Popen,PIPE
import sys
import time
import math

normalize = {}

colors = ['\033[34m', '\033[35m','\033[37m','\033[93m','\033[32m','\033[33m','\033[36m','\033[31m']
weight = 100

def runCMD(cmd):
    p = Popen(cmd,shell=True, stdout=PIPE, stderr=PIPE)
    out,err = p.communicate()
    if(p.returncode !=0):
        print "Return code: ", p.returncode
        print err.rstrip()

    resultsLine = out.rstrip()

    return resultsLine


def check_interfaces(ifaces):
	iface_data = {}
	for eth in ifaces:
		cmd ="ifconfig "+eth+" | grep 'RX bytes'"
		iface_data[eth]= runCMD(cmd).strip().split(" ")
	return iface_data
		
def print_data(ifaces,iface_data):
	print(chr(27) + "[2J")
	unit_constant = 1000000000
	unit_str = "GB"
	for eth in ifaces:
		print eth
		print "\tTX: Total: "+iface_data[eth][1][0]+"  "+str(float(iface_data[eth][1][0])/unit_constant)+unit_str
		print "\tSession TX: "+str(int(iface_data[eth][1][0])-int(normalize[eth][1]))+"  "+str((float(iface_data[eth][1][0])-float(normalize[eth][1]))/unit_constant)+unit_str
		print "\tRX: Total: "+iface_data[eth][0][0]+"  "+"  "+str(float(iface_data[eth][0][0])/unit_constant)+unit_str
		print "\tSession RX: "+str(int(iface_data[eth][0][0])-int(normalize[eth][0]))+"  "+str((float(iface_data[eth][0][0])-float(normalize[eth][0]))/unit_constant)+unit_str

#Processes for received data
# Takes in data string and iface name
#returns tuple of (bytes,human_readableUNITS)
def process_rx(data,iface):
	#Split on bytes
	bytes_tmp = data[1].split(':')
	num_bytes = bytes_tmp[1]
	human_format = data[2].replace('(','')
	units = data[3].replace(')','')
	return (num_bytes,human_format+units)

	
#Processes for transmitted data
# Takes in data string and iface name
#returns tuple of (bytes,human_readableUNITS)
def process_tx(data,iface):
	#Split on bytes
	bytes_tmp = data[6].split(':')
	num_bytes = bytes_tmp[1]
	human_format = data[7].replace('(','')
	units = data[8].replace(')','')
	return (num_bytes,human_format+units)

#iterates over interfaces and fetches TX and RX data
#returns dictionary of tuple of the form
# eth_name = (tx_data, received_data)
def fetch_iface_data(ifaces,iface_data):
	iface_parsed_data = {}
	for eth in ifaces:
		rx_res = process_rx(iface_data[eth],eth)	
		tx_res = process_tx(iface_data[eth],eth)	
		iface_parsed_data[eth] = (rx_res,tx_res)
	return iface_parsed_data


#Runs first to set up normalized data
def init(ifaces):
	global normalize
	iface_data = check_interfaces(ifaces)
	iface_parsed_data = fetch_iface_data(ifaces,iface_data)
	set_normalized_constants(iface_parsed_data,ifaces)



def poll_data(ifaces):
	global normalize
	iface_data = check_interfaces(ifaces)
	iface_parsed_data = fetch_iface_data(ifaces,iface_data)
	print_data(ifaces,iface_parsed_data)
	#Generate percentages for TX
	bytes_list = []
	shares = []
	for eth in ifaces:
		bytes_list.append(int(iface_parsed_data[eth][1][0])-int(normalize[eth][1]))	
	shares = gen_percentages(bytes_list)
	#Generate graph for TX
	generate_graph(shares,"Interface TX Usage:",ifaces) 
	bytes_list = []
	shares = []
	for eth in ifaces:
		bytes_list.append(int(iface_parsed_data[eth][0][0])-int(normalize[eth][0]))	
	shares = gen_percentages(bytes_list)
	generate_graph(shares,"Interface RX Usage:",ifaces) 
	time.sleep(.5)
	
def set_normalized_constants(iface_parsed_data,ifaces):
	global normalize
	for eth in ifaces:
		normalize[eth] =   (iface_parsed_data[eth][0][0],iface_parsed_data[eth][1][0])


##Generates percentages for each interface
##Expects a list of the form [bytes,bytes,bytes,bytes]
def gen_percentages(values):
	total = 0
	#for i in range(0,len(values)):
	for i in values:
		#total += values[i]
		total += i
	share = []
	for i in values:
		#x1_share = math.floor((x1 / float(total))*weight)
		if total == 0:
			share.append(0)
		else:
			share.append(math.floor((i/float(total))*weight))
	return share

#generates graph
##Expects list of form [share,share,share]
def generate_graph(shares,title,ifaces):
	global colors
	temp_colors = list(colors)
	print title
	for i in range(0,len(shares)):
		color = temp_colors.pop()
		print ifaces[i]+": "+generate_graph_bar(shares[i],color)

#Generates bar for graph
def generate_graph_bar(share,color):
	graph_value = "["+color
	for i in range(0,weight):
		if i <= share:
			graph_value = graph_value+"|"	
		else:
			graph_value = graph_value+" "
	return graph_value+'\033[0m'+" "+str(share)+"%]"







if __name__ == "__main__":
	#If no interface provided error out
	if len(sys.argv) == 1:
		print "Usage: python "+sys.argv[0]+" interface_name1 interface_name2 ..."
		exit(0)
	ifaces = []	
	for i in range(1,len(sys.argv)):
		ifaces.append(sys.argv[i])
	init(ifaces)
	while True:
		poll_data(ifaces)		
	#iface_data = check_interfaces(ifaces)
#	print iface_data
	#print_data(iface_data,ifaces)
	#iface_parsed_data = fetch_iface_data(ifaces,iface_data)
