set title "NETWORK TRAFFIC"

set xdata time
set timefmt "%Y/%m/%d %H"
set format x "%m/%d\n%H:00"

set xlabel "DATE"

set ylabel "THRUPUT [kbps]"
set yrange [1:]
set logscale y

set data style lines
set grid
set key top left

set terminal pbm color
set output "|../bin/ppmtogif >0001net.gif 2>/dev/null"

plot "tmp0001net" using 1:5 title "RX MAX", \
     "tmp0001net" using 1:4 title "RX AVG", \
     "tmp0001net" using 1:8 title "TX MAX", \
     "tmp0001net" using 1:7 title "TX AVG"
