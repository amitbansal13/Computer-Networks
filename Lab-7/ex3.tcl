set ns [new Simulator]
$ns color 1 Red
$ns color 2 Blue
set f0 [open out0.tr w]
set f1 [open out1.tr w]
set f2 [open out2.tr w]
set f3 [open temp.txt w]
set nf [open out.nam w]

set tf [open outall.tr w]
$ns trace-all $tf

set t0 0.0
set t1 0.0
$ns namtrace-all $nf

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

proc finish {} {
    global ns nf f0 f1 f2 f3 t0 t1
    $ns flush-trace
    set t0 [expr $t0*8/30000000]
    set t1 [expr $t1*8/30000000]
    puts $f3 "Throughput TCP = $t0"
    puts $f3 "Throughput UDP = $t1"
    close $nf
    close $f0
    close $f1
    close $f2
    close $f3
    exec nam out.nam &
    exec xgraph out0.tr out2.tr -geometry 800x400 &
    exec xgraph out1.tr -geometry 800x400 &
    #exec xgraph out2.tr -geometry 800x400 &
    #exec xgraph out3.tr -geometry 800x400 &
    exit 0
}
proc record {} {
    global sink0 sink1 f0 f1 f2 t0 t1 tcp udp
    set ns [Simulator instance]
    set time .1
    set cwnd [$tcp set cwnd_]
    set bw0 [$sink0 set bytes_]
    set bw1 [$sink1 set bytes_]
    set t0 [expr $t0 + $bw0]
    set t1 [expr $t1 + $bw1]
    set now [$ns now]
    puts $f0 "$now [expr $bw0/$time*8/1000000]"
    puts $f1 "$now $cwnd"
    puts $f2 "$now [expr $bw1/$time*8/1000000]"
    # puts $f3 "$now $cwnd2"
    $sink0 set bytes_ 0
    $sink1 set bytes_ 0
    $ns at [expr $now+$time] "record"
}

$ns duplex-link $n0 $n1 2Mb 100ms DropTail
$ns duplex-link $n1 $n2 2Mb 100ms DropTail
$ns duplex-link $n3 $n1 2Mb 100ms DropTail

set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp
$tcp set fid_ 1
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$tcp set packet_size_ 512

set sink0 [new Agent/TCPSink]
$ns attach-agent $n2 $sink0

set udp [new Agent/UDP]
$ns attach-agent $n3 $udp

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set packet_size_ 800
$cbr set interval_ 0.005
$udp set fid_ 2
set sink1 [new Agent/LossMonitor]
$ns attach-agent $n2 $sink1

$ns connect $udp $sink1
$ns connect $tcp $sink0

$ns at 0.0 "record"
$ns at 1.0 "$ftp start"
$ns at 10.0 "$cbr start"
$ns at 30.0 "$cbr stop"

$ns at 30.0 "$ftp stop"
$ns at 30.0 "finish"

$ns run
