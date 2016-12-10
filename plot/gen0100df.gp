load "../plot/common.gp"

set title "STORAGE UTILIZATION"

set yrange [0:100]
set ylabel "PERCENT"

set output output_fname("0100df")

load "../conf/dfplot.gp"
