set title "MEMORY USAGE"

set xdata time
set timefmt "%Y/%m/%d %H:%M"
set format x "%m/%d\n%H:%M"

set yrange [0:100]

set data style lines
set grid
set key bottom left

set terminal pbm color
set output "|../bin/ppmtogif >0005mem.gif 2>/dev/null"

plot "tmp0005mem" using 1:3 title "CACHE", \
     "tmp0005mem" using 1:4 title "BUFF", \
     "tmp0005mem" using 1:5 title "RSS", \
     "tmp0005mem" using 1:6 title "SWAP"
