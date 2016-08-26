package main

import(
	"os/exec"
	"fmt"
	"strings"
	"os"
	"strconv"
	"time"
	"flag"
	"bufio"
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
var mode = "tx"
var interface_list []string
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

func check(e error){
	if e != nil{
		panic(e)
	}
}



func collect_band(c chan *bytes, interfaces []string){
    //var points =bytes{0,0,0,0}
    var points *bytes
	points = <-c
    f,err := os.Create("/tmp/interface_data")
	for index,element := range interfaces{
		if index != len(interfaces)-1 {
			f.WriteString(element+",")
		}else{
			f.WriteString(element+"\n")
		}
	}
    check(err)
	for{
			for index,element := range interfaces{
				cmd := exec.Command("cat","/sys/class/net/"+element+"/statistics/"+mode+"_bytes")
				output,err := cmd.CombinedOutput()
				check(err)

				output_str := strings.Replace(string(output),"\n","",1)
				if index != len(interfaces)-1 {
						_,err := f.WriteString(output_str+",")
						check(err)
				}else{
						_,err := f.WriteString(output_str+"\n")
						check(err)
				}
				f.Sync()

				i,err := strconv.Atoi(output_str)
				if index == 0{
					points.eth0 = i
				}else if  index == 1{
					points.eth1 = i
				}else if  index == 2{
					points.eth2 = i
				}else if  index == 3{
					points.eth3 = i
				}
				
			}
			c <- points
			time.Sleep(time.Second)
		}


}



func collect_bandwidth(c chan *bytes){
	var points *bytes;
	points = <-c
	f,err := os.Create("/tmp/interface_data")
	check(err)
	fmt.Println("received pointer")
	for{
				// Create an *exec.Cmd
		cmd := exec.Command("cat", "/sys/class/net/eno1/statistics/"+mode+"_bytes")
		output, err := cmd.CombinedOutput()

		cmd2 := exec.Command("cat", "/sys/class/net/eno2/statistics/"+mode+"_bytes")
		output2, err := cmd2.CombinedOutput()

		cmd3 := exec.Command("cat", "/sys/class/net/eth2/statistics/"+mode+"_bytes")
		output3, err := cmd3.CombinedOutput()

		cmd4 := exec.Command("cat", "/sys/class/net/eth3/statistics/"+mode+"_bytes")
		output4, err := cmd4.CombinedOutput()



		output_str := strings.Replace(string(output), "\n", "", 1)
		output_str2 := strings.Replace(string(output2), "\n", "", 1)
		output_str3 := strings.Replace(string(output3), "\n", "", 1)
		output_str4 := strings.Replace(string(output4), "\n", "", 1)
		_,err = f.WriteString(output_str+","+output_str2+","+output_str3+","+output_str4+"\n")
		check(err)
		f.Sync()
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
/* function that parses lines */
func parse_file_line(line string)[]string{
	data := strings.Split(line,",")
	return data
}

/* Gofunc that reads the lines from the file and then sends back the correct data */
func read_band(c chan *bytes,fname string){
	var points *bytes
	file,err := os.Open(fname)
	check(err)
	defer file.Close()
	points = <-c
	first := true
	scanner := bufio.NewScanner(file)
	scanner.Text() //read first line, contains interface name
	for scanner.Scan(){
		data := parse_file_line(scanner.Text())
		if first {
			first = false
			continue
		}
		for index,element := range data{
				output_str := strings.Replace(element,"\n","",1)

				i,err := strconv.Atoi(output_str)
				check(err)
				if index == 0{
					points.eth0 = i
				}else if  index == 1{
					points.eth1 = i
				}else if  index == 2{
					points.eth2 = i
				}else if  index == 3{
					points.eth3 = i
				}
			}
		c <- points
		time.Sleep(time.Second)

	}
}

/* Function that handles replay functionality */
func replay(fname string){
	c := make(chan *bytes)
	t := bytes{}
	data := bytes{}
	prev := bytes{0,0,0,0}
	//go collect_bandwidth(c)
	go read_band(c,fname)
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


func draw_graph(data bytes){
	
	
	fmt.Println("\033[H\033[2J")
	fmt.Println("Network Interface Usage as Percentage of Interface Capacity")
	fmt.Println("Link Capacity: "+strconv.Itoa(int(link_capacity))+"      Mode: "+mode)
	fmt.Println("eth0: "+gen_bar(data.eth0,colors[0]))	
	fmt.Println("eth1: "+gen_bar(data.eth1,colors[1]))	
	fmt.Println("eth2: "+gen_bar(data.eth2,colors[2]))	
	fmt.Println("eth3: "+gen_bar(data.eth3,colors[3]))	

}


/*fucntion to parse interfaces to use*/
func parseInterfaces(ints string){
    interface_list = strings.Split(ints,",")
    fmt.Println("Interfaces are:")
    for _,element := range interface_list{
        fmt.Println(element)
    }

	interface_list[len(interface_list)-1]= strings.Replace(interface_list[len(interface_list)-1],"\n","",1)
}


func printHelp(){
	fmt.Println("How to the interface monitor. Call it like so:")
	fmt.Println("Default:\n\t ./collect \n This will print tx stats and default to a max fo 1Gbit.")
	fmt.Println("Specify Mode:\n\t ./collect -m [ tx | rx ]  \n This will print either received or transmited stats")
	fmt.Println("Specify Link Capacity(in Mbits):\n\t ./collect -l 2000 \n This will use 2000 megabits as the link capacity")
	fmt.Println("Specify Interfaces:\n\t ./collect -i eth1,eth2 \n This will use only interface eth1 and eth2")
	fmt.Println("Replay a past trace:\n\t ./collect -r -f /path/to/trace \n This will allow you to replay a past trace")
	os.Exit(0)


}


func main(){
	c := make(chan *bytes)
	var interfaces =""
	var filename string
	//parse flags
	flag.Float64Var(&link_capacity,"l",1000," max link capacity in bytes")
	flag.StringVar(&mode,"m","tx","either use tx or rx")
	flag.StringVar(&filename,"f","","specify the full path")
	help := flag.Bool("h",false,"Show help")
	r := flag.Bool("r",false,"Replay a past attempt")
	flag.StringVar(&interfaces,"i","lo","Interfaces to read. Max 4. format: eth1,eth2,eth3")
	flag.Parse()
	parseInterfaces(interfaces)
	if *help{
		printHelp()
	}
	if *r{
		if filename == ""{
			printHelp()
		}
		replay(filename)
	}
	if strings.EqualFold(mode,"rx")!=true && strings.EqualFold(mode,"tx") != true{

		printHelp()
	}
	t := bytes{}
	data := bytes{}
	prev := bytes{0,0,0,0}
	//go collect_bandwidth(c)
	go collect_band(c,interface_list)
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
