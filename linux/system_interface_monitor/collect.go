package main

import(
	"os/exec"
	"fmt"
	"strings"
	"os"
	"strconv"
	"time"
)


type bytes struct {
	eth0 int
	eth1 int
	eth2 int
	eth3 int
}


//colors = [...]{'\033[34m', '\033[35m','\033[37m','\033[93m','\033[32m','\033[33m','\033[36m','\033[31m'}
var colors = [...]string{"\033[34m", "\033[35m","\033[37m","\033[93m","\033[32m","\033[33m","\033[36m","\033[31m"}

var link_capacity = 1000.0

func printCommand(cmd *exec.Cmd) {
  fmt.Printf("==> Executing: %s\n", strings.Join(cmd.Args, " "))
}

func printError(err error) {
  if err != nil {
    os.Stderr.WriteString(fmt.Sprintf("==> Error: %s\n", err.Error()))
  }
}

func printOutput(outs []byte) {
  if len(outs) > 0 {
    fmt.Printf("==> Output: %s\n", string(outs))
  }
}



func collect_bandwidth(c chan *bytes){
	var points *bytes;
	points = <-c

	fmt.Println("received pointer")
	for{
				// Create an *exec.Cmd
		cmd := exec.Command("cat", "/sys/class/net/eth0/statistics/tx_bytes")
		output, err := cmd.CombinedOutput()

		cmd2 := exec.Command("cat", "/sys/class/net/eth1/statistics/tx_bytes")
		output2, err := cmd2.CombinedOutput()

		cmd3 := exec.Command("cat", "/sys/class/net/eth2/statistics/tx_bytes")
		output3, err := cmd3.CombinedOutput()

		cmd4 := exec.Command("cat", "/sys/class/net/eth3/statistics/tx_bytes")
		output4, err := cmd4.CombinedOutput()



		output_str := strings.Replace(string(output), "\n", "", 1)
		output_str2 := strings.Replace(string(output2), "\n", "", 1)
		output_str3 := strings.Replace(string(output3), "\n", "", 1)
		output_str4 := strings.Replace(string(output4), "\n", "", 1)
		i,err := strconv.Atoi(output_str)
		if err != nil{
			fmt.Println(err)
		}
		points.eth0 = i

		i,err = strconv.Atoi(output_str2)
		if err != nil{
			fmt.Println(err)
		}
		points.eth1 = i

		i,err = strconv.Atoi(output_str3)
		if err != nil{
			fmt.Println(err)
		}
		points.eth2 = i

		i,err = strconv.Atoi(output_str4)
		if err != nil{
			fmt.Println(err)
		}
		points.eth3 = i
		c <- points
		time.Sleep(time.Second)
	}
}

func calc_bandwidth(tx int,prev int)int{
	diff := tx -prev
	bits := diff * 8
	
	megabits := bits/1000000
	return megabits
}


func gen_bar(data int, color string)string{
	proportion_float := (float64(data)/link_capacity)*100
	proportion := int(proportion_float)
	bar := "["+color
	for i := 1; i<=100; i++{
		if i <= proportion{
			bar = bar +"|"
		}else{
			bar = bar+" "
		}
	}
	return bar+"\033[0m"+" "+strconv.Itoa(proportion)+"%] "+strconv.Itoa(data)+" Mbits/sec"
}

func draw_graph(data bytes){
	
	
	fmt.Println("\033[H\033[2J")
	fmt.Println("Network Interface Usage as Percentage of Interface Capacity")
	fmt.Println("Link Capacity: "+strconv.Itoa(int(link_capacity)))
	fmt.Println("eth0: "+gen_bar(data.eth0,colors[0]))	
	fmt.Println("eth1: "+gen_bar(data.eth1,colors[1]))	
	fmt.Println("eth2: "+gen_bar(data.eth2,colors[2]))	
	fmt.Println("eth3: "+gen_bar(data.eth3,colors[3]))	

}


func main(){
	c := make(chan *bytes)
	if len(os.Args)>1{
		f, err := strconv.ParseFloat(os.Args[1], 64)
		if err != nil{
			fmt.Println(err)
		}
		link_capacity = f
	}
	t := bytes{}
	data := bytes{}
	prev := bytes{0,0,0,0}
	go collect_bandwidth(c)
	c <- &t
	for{
		i := <-c
		//eth0_data := calc_bandwidth(i.eth0,prev.eth0)
		data.eth0 = calc_bandwidth(i.eth0,prev.eth0)
		prev.eth0 = i.eth0

		//eth1_data := calc_bandwidth(i.eth1,prev.eth1)
		data.eth1 = calc_bandwidth(i.eth1,prev.eth1)
		prev.eth1 = i.eth1

	//	eth2_data := calc_bandwidth(i.eth2,prev.eth2)
		data.eth2 = calc_bandwidth(i.eth2,prev.eth2)
		prev.eth2 = i.eth2

		//eth3_data := calc_bandwidth(i.eth3,prev.eth3)
		data.eth3 = calc_bandwidth(i.eth3,prev.eth3)
		prev.eth3 = i.eth3

	/*	fmt.Println(eth0_data)
		fmt.Println(eth1_data)
		fmt.Println(eth2_data)
		fmt.Println(eth3_data) */
		draw_graph(data)

	}


}
