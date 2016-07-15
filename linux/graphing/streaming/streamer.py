# myplot.py
from bokeh.plotting import figure, curdoc
from bokeh.driving import linear
from bokeh.client import push_session
import sys
import random

p = figure(plot_width=400, plot_height=400)
r1 = p.line([], [], color="firebrick", line_width=2)

ds1 = r1.data_source

# open a session to keep our local document in sync with server
session = push_session(curdoc(),"iperf")

@linear()
def update(step):
	s = sys.stdin.readline()
	if not s:
		return 
	values = s.split(",")
	if len(values) == 0 or len(values) == 1:
		return
	interval = values[6].split("-")
	interval = interval[1].split(".")
	values[8]= values[8].rstrip()	
	ds1.data['x'].append(int(interval[0]))
	ds1.data['y'].append(int(values[8])/1000000)
	ds1.trigger('data', ds1.data, ds1.data)

curdoc().add_root(p)

# Add a periodic callback to be run every 500 milliseconds
curdoc().add_periodic_callback(update, 1000)
print "http://52.206.72.10:5006/?bokeh-session-id=iperf"
#session.show() # open the document in a browser

session.loop_until_closed() # run forever
