package main

import(
	"fmt"
	"net"
	"os"
	"strings"
)


func main(){
	fmt.Println("Launching server...")

	//listen on all interfaces
	ln,err := net.Listen("tcp", ":8081")
	if err != nil{
	   fmt.Println("Error Listening:",err.Error())
	   os.Exit(1)
	}
	defer ln.Close()
	//run loop forever
	for{
		conn,err := ln.Accept()
		if err!=nil{
		   fmt.Println("Error Accepting:",err.Error())
		   os.Exit(1)
		}
		//Handle connections
		go handleRequest(conn)
	}
}


func handleRequest(conn net.Conn){
     //buffer to hold data
     buf := make([]byte,1024)
     var totaldata = 0
     var counter = 0
     for{
	counter++
     	//Read incoming connection
     	reqLen, err := conn.Read(buf)

     	if err != nil{
     		fmt.Println("Error reading:",err.Error())
     	}
        totaldata += reqLen
	if counter % 100 ==0{
    		fmt.Println("Total Data is :",totaldata)
	}
	
     	//Send message back
   	  //conn.Write([]byte("Message received"))
	if strings.Contains(string(buf),"EOF"){
		conn.Write([]byte("Complete\n"))
		os.Exit(1)
	}
     }
     //close connection
     conn.Close()
}
