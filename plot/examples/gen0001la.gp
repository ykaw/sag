load "../plot/common.gp"

set title "LOAD AVERAGE"

set yrange [0:]

set output output_fname("0001la")

plot "sumtmp-0001la" using 1:5 title "MAX/HR", \
     "sumtmp-0001la" using 1:3 title "MIN/HR", \
     "sumtmp-0001la" using 1:4 title "AVG/HR" with steps
