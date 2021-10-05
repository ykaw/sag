load "../plot/common.gp"

set title "NETWORK TRAFFIC"

set logscale y
set ylabel "kbps"

set output output_fname("0001net")

plot "sumtmp-0001net" using 1:8 title "TX MAX/HR", \
     "sumtmp-0001net" using 1:5 title "RX MAX/HR", \
     "sumtmp-0001net" using 1:7 title "TX AVG/HR" with steps, \
     "sumtmp-0001net" using 1:4 title "RX AVG/HR" with steps
