set ns [new Simulator]
$ns color 1 Red
$ns color 2 Blue
#for throughput
set f0 [open tcp10.tr w]
#for cwnd
set f1 [open tcp11.tr w]

set f2 [open tcp20.tr w]
set f3 [open tcp21.tr w]
set nf [open out.nam w]

$ns namtrace-all $nf

set tf [open outall.tr w]
$ns trace-all $tf

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]

proc finish {} {
    global ns nf f0 f1 f2 f3 tf
    $ns flush-trace
    close $nf
    close $f0
    close $f1
    close $f2
    close $f3
    close $tf
    exec nam out.nam &
    exec xgraph tcp10.tr tcp20.tr -geometry 800x400 &
    exec xgraph tcp11.tr -geometry 800x400 &
    #exec xgraph out2.tr -geometry 800x400 &
    exec xgraph tcp21.tr -geometry 800x400 &
    exit 0
}
proc record {} {
    global sink0 sink1 f0 f1 f2 f3 tcp tcp1
    set ns [Simulator instance]
    set time .1
    set cwnd [$tcp set cwnd_]
    set cwnd2 [$tcp1 set cwnd_]
    set bw0 [$sink0 set bytes_]
    set bw1 [$sink1 set bytes_]
    set now [$ns now]
    puts $f0 "$now [expr $bw0/$time*8/1000000]"
    puts $f1 "$now $cwnd"
    puts $f2 "$now [expr $bw1/$time*8/1000000]"
    puts $f3 "$now $cwnd2"
    $sink0 set bytes_ 0
    $sink1 set bytes_ 0
    $ns at [expr $now+$time] "record"
}
$ns duplex-link $n4 $n0 2Mb 100ms DropTail
$ns duplex-link $n0 $n1 2Mb 100ms DropTail
$ns duplex-link $n1 $n2 1Mb 100ms DropTail
$ns duplex-link $n3 $n1 2Mb 100ms DropTail

$ns queue-limit $n1 $n2 2

set tcp [new Agent/TCP]
$ns attach-agent $n4 $tcp
$tcp set fid_ 1
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$tcp set packet_size_ 512

set sink0 [new Agent/TCPSink]
$ns attach-agent $n2 $sink0

set tcp1 [new Agent/TCP]
$ns attach-agent $n3 $tcp1

set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$tcp1 set packet_size_ 512
$tcp1 set fid_ 2
set sink1 [new Agent/TCPSink]
$ns attach-agent $n2 $sink1

$ns connect $tcp1 $sink1
$ns connect $tcp $sink0

$ns at 0.0 "record"
$ns at 1.0 "$ftp start"
$ns at 1.0 "$ftp1 start"
$ns at 30.0 "$ftp1 stop"

$ns at 30.0 "$ftp stop"
$ns at 30.0 "finish"

$ns run
