set title "DISK USAGE"

set xdata time
set timefmt "%Y/%m/%d %H"
set format x "%m/%d\n%H:00"

# set yrange [0:100]

set data style lines
set grid
set key bottom left

set terminal pbm color
set output "|../bin/ppmtogif >0100df.gif 2>/dev/null"

plot "tmp0100df" using 1:3, \
     "tmp0100df" using 1:4, \
     "tmp0100df" using 1:5, \
     "tmp0100df" using 1:6, \
     "tmp0100df" using 1:7
