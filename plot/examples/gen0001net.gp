load "../plot/common.gp"

set title "NETWORK TRAFFIC"

set logscale y
set ylabel "kbps"

set output output_fname("0001net")

plot "sumtmp-0001net" using 1:8 title "TX_MAX/HR", \
     "sumtmp-0001net" using 1:5 title "RX_MAX/HR", \
     "sumtmp-0001net" using 1:7 title "TX_AVG/HR" with steps, \
     "sumtmp-0001net" using 1:4 title "RX_AVG/HR" with steps
