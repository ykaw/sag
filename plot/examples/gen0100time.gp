load "../plot/common.gp"

set title "CLOCK DRIFT"

set ylabel "PPM"

set output output_fname("0100time")

# for old ntp.drift
#
plot "sumtmp-0100time" using 1:(abs($3)<1 ? 1000000*$3 : $3) title ""
