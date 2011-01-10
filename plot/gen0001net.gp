set title "NETWORK TRAFFIC"

set xdata time
set timefmt "%Y/%m/%d %H"
set format x "%m/%d\n%H:00"

set xlabel "DATE"

set ylabel "THRUPUT [kbps]"
set logscale y

set grid
set key top left

set terminal pbm color
set output "|../bin/pnminvert|../bin/ppmtogif >0001net.gif 2>/dev/null"

plot "sumtmp-0001net" using 1:5 title "RX MAX" with dots, \
     "sumtmp-0001net" using 1:4 title "RX AVG" with steps, \
     "sumtmp-0001net" using 1:8 title "TX MAX" with dots, \
     "sumtmp-0001net" using 1:7 title "TX AVG" with steps
