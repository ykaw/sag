load "../plot/common.gp"

set title "NTP STATUS"

set style data steps
set logscale y
set yrange [0.001:]
set ylabel "millisecond"

set output output_fname("0005timeofs")

plot "sumtmp-0005timeofs" using 1:4 title "DELAY"  with steps lc 1, \
     "sumtmp-0005timeofs" using 1:5 title "JITTER" with steps lc 2, \
     "sumtmp-0005timeofs" using 1:(0<$3 ?  $3 : 1/0) title "+OFFSET" with steps lc 3, \
     "sumtmp-0005timeofs" using 1:($3<0 ? -$3 : 1/0) title "-OFFSET" with steps lc 4
