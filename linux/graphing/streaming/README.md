



# Running the script
- Start the bokeh server
``` 
bokeh serve --address=0.0.0.0 --host='*'
```
- Run the python script by feeding data into stdin
```
iperf -c mptcp_host -y c -t 300 -i 1 | python streamer.py
``` 
- Visit this webpage: http://IP_OF_HOST:5006/?bokeh-session-id=iperf
