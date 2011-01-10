set title "LOAD AVERAGES"

set xdata time
set timefmt "%Y/%m/%d %H"
set format x "%m/%d\n%H:00"

set yrange [0:]

set grid
set key top left

set terminal pbm color
set output "|../bin/pnminvert|../bin/ppmtogif >0001la.gif 2>/dev/null"

plot "sumtmp-0001la" using 1:5 title "MAX" with dots, \
     "sumtmp-0001la" using 1:4 title "AVG" with steps, \
     "sumtmp-0001la" using 1:3 title "MIN" with dots
