package main

import (
	"fmt"
	"io/ioutil"
	"net"
	"bufio"
	"time"
_	"os"

)


func check(e error){
	if e != nil{
		panic(e)
	}
}

//generates a five gb file
func gen_file(text string, large_text *string){
	fmt.Printf("Starting size of text-input %d\n",len(text))
	//loop_range := 29941 //five gb
	loop_range := 5989
	for i :=0; i < loop_range; i++{
        	*large_text += text
	}
	fmt.Println("done generating data")
}


func main(){
	fmt.Println("Begin Reading File")
	dat, err := ioutil.ReadFile("alice-orig.txt")
	check(err)
	fmt.Println("Done Reading File")
//	fmt.Print(string(dat))
//	large_text := ""
//	text := gen_file(string(dat),&large_text)	
//	fmt.Printf("size is %d\n",len(large_text))
	

	fmt.Printf("size is %d\n",len(dat))
	//connect to socket
	conn, err := net.Dial("tcp","10.0.1.5:8081")
	check(err)
	fmt.Println("Sending data now")
	start := time.Now()
	var elapsed time.Duration
	for{
		//send data

		for i :=0; i < 59880; i++{
			fmt.Fprintf(conn,string(dat))
		}
		fmt.Fprintf(conn,string(dat)+"EOF")
		//listen for reply
		message,_:=bufio.NewReader(conn).ReadString('\n')
		fmt.Print("Message from server: "+message)
		if message == "Complete\n"{
			elapsed = time.Since(start)
			break
		}
	} 
	fmt.Println("Operation Complete")
	fmt.Printf("Total Time to Send %d Bytes Was %s\n",len(dat)*59880,elapsed)
}
