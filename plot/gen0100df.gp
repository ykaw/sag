load "../plot/common.gp"

set title "STORAGE UTILIZATION"

set yrange [0:100]
set ylabel "PERCENT"

set output output_fname("0100df")

plot "sumtmp-0100df" using 1:3 title "ROOT", \
     "sumtmp-0100df" using 1:4 title "SYSTEM", \
     "sumtmp-0100df" using 1:5 title "USER", \
     "sumtmp-0100df" using 1:6 title "WEB", \
     "sumtmp-0100df" using 1:7 title "EXTRA"
