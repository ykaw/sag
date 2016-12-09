load "../plot/common.gp"

set title "MEMORY UTILIZATION"

set ylabel "MEGABYTES"

set output output_fname("0005mem")

plot "sumtmp-0005mem" using 1:($3/1048576) title "ACTIVE", \
     "sumtmp-0005mem" using 1:($4/1048576) title "TOTAL",  \
     "sumtmp-0005mem" using 1:($5/1048576) title "FREE",   \
     "sumtmp-0005mem" using 1:($6/1048576) title "CACHE",  \
     "sumtmp-0005mem" using 1:($7/1048576) title "SWAP"
