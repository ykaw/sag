load "../plot/common.gp"

set title "NTP STATUS"

set logscale y
set yrange [0.001:]
set ylabel "millisecond"

set output output_fname("0005timeofs")

plot "sumtmp-0005timeofs" using 1:4 title "DELAY" , \
     "sumtmp-0005timeofs" using 1:5 title "JITTER", \
     "sumtmp-0005timeofs" using 1:3 title "OFFSET+" with steps
