load "../plot/common.gp"

set title "CLOCK DRIFT"

set ylabel "PPM"

set output output_fname("0100time")

plot "sumtmp-0100time" using 1:3 title ""
