set title "MEMORY USAGE"

set xdata time
set timefmt "%Y/%m/%d %H:%M"
set format x "%m/%d\n%H:%M"

set yrange [0:100]

set data style lines
set grid
set key bottom left

set terminal pbm color
set output "|../bin/pnminvert|../bin/ppmtogif >0005mem.gif 2>/dev/null"

plot "sumtmp-0005mem" using 1:3 title "MEM", \
     "sumtmp-0005mem" using 1:6 title "SWAP"
