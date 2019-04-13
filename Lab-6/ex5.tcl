set ns [new Simulator]

set f0 [open out3.tr w]
set f1 [open out1.tr w]
set nf [open out.nam w]
set f2 [open temp.txt w]
set t0 0.0
set t1 0.0

$ns namtrace-all $nf

set tf [open outall.tr w]
$ns trace-all $tf

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
$ns color 1 Blue 
$ns color 2 Red 

$ns duplex-link $n0 $n2 4Mb 10ms DropTail
$ns duplex-link $n1 $n2 2Mb 10ms DropTail
$ns duplex-link $n2 $n3 2Mb 10ms DropTail

proc finish {} {
	global f0 f1 nf tf t0 t1 f2
	puts $f2 "Throughput [expr $t0*8/10000000]"
	puts $f2 "Throughput [expr $t1*8/10000000]"
	close $nf
	close $tf
	close $f0
	close $f1
	exec xgraph out0.tr out1.tr -geometry 800x400 &
	exec nam out.nam &
	exit 0
}

proc record {} {
	global sink0 sink1 f0 f1 t0 t1
	set ns [Simulator instance]
	
	set time .1
	
	set bw0 [$sink0 set bytes_]
	set bw1 [$sink1 set bytes_]
	set t0 [expr $t0+$bw0]
	set t1 [expr $t1+$bw1]
	set now [$ns now]
	puts $f0 "$now [expr $bw0/$time*8/1000000]"
	puts $f1 "$now [expr $bw1/$time*8/1000000]"
	$sink0 set bytes_ 0
	$sink1 set bytes_ 0
	$ns at [expr $now+$time] "record"
}


set sink0 [new Agent/LossMonitor]
set sink1 [new Agent/TCPSink]

$ns attach-agent $n3 $sink0
$ns attach-agent $n3 $sink1


set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0

set cbr0 [new Application/Traffic/CBR]
$cbr0 set packet_size_ 500
$cbr0 set interval_ 0.005
$cbr0 attach-agent $udp0

$ns connect $udp0 $sink0


set tcp0 [new Agent/TCP]
$ns attach-agent $n1 $tcp0

set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp0

$ftp1 set packet_size_ 500
$ftp1 set interval_ 0.005

$ns connect $tcp0 $sink1


$ns at 0.0 "record"
$ns at 0.0 "$ftp1 start"
$ns at 5.0 "$cbr0 start"
$ns at 10.0 "$ftp1 stop"
$ns at 10.0 "$cbr0 stop"
$ns at 10.0 "finish"


$ns run


