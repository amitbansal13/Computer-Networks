set ns [new Simulator]

set f0 [open out0.tr w]
set nf [open out.nam w]
set f1 [open out1.tr w]

$ns namtrace-all $nf

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]

proc finish {} {
    global ns nf f0 f1
    $ns flush-trace
    close $nf
    close $f0
    close $f1
    exec nam out.nam &
    exec xgraph out0.tr -geometry 800x400 &
    exec xgraph out1.tr -geometry 800x400 &
    exit 0
}
proc record {} {
    global sink0 f0 f1 tcp
    set ns [Simulator instance]
    set time .1
    set cwnd [$tcp set cwnd_]
    set bw0 [$sink0 set bytes_]
    set now [$ns now]
    puts $f0 "$now [expr $bw0/$time*8/1000000]"
    puts $f1 "$now $cwnd"
    $sink0 set bytes_ 0
    $ns at [expr $now+$time] "record"
}
$ns duplex-link $n0 $n1 2Mb 100ms DropTail
$ns duplex-link $n1 $n2 2Mb 100ms DropTail

set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp

set ftp [new Application/FTP]
$ftp attach-agent $tcp
$tcp set packet_size_ 512

set sink0 [new Agent/TCPSink]
$ns attach-agent $n2 $sink0

$ns connect $tcp $sink0

$ns at 0.0 "record"
$ns at 1.0 "$ftp start"
$ns at 30.0 "$ftp stop"
$ns at 30.0 "finish"

$ns run