#!/home/lucasch/anaconda/bin/python

import smtplib

fromaddr ="lucasch@cs.umass.edu"
#toaddrs = "lucaschaufournier@gmail.com"
toaddrs = "3018202080@txt.att.net"
msg = "The script is done"


#Credentials
username = ""
password = ""

#Sending
#server = smtplib.SMTP('smtp.gmail.com:587')
server = smtplib.SMTP('mail.cs.umass.edu')
server.starttls()
server.login(username,password)
server.sendmail(fromaddr,toaddrs,msg)
server.quit()
