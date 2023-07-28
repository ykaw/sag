load "../plot/common.gp"

set title "PROCESS INVOCATION"

set logscale y
set ylabel "FORKS/MIN"

set output output_fname("0001procs")

plot "sumtmp-0001procs" using 1:3 title "MIN" with points, \
     "sumtmp-0001procs" using 1:5 title "MAX" with points, \
     "sumtmp-0001procs" using 1:4 title "AVG" with steps
