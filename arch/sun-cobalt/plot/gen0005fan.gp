set title "FAN SPEED"

set xdata time
set timefmt "%Y/%m/%d %H:%M"
set format x "%m/%d\n%H:%M"

set data style lines
set grid
set key bottom left

set terminal pbm color
set output "|../bin/ppmtogif >0005fan.gif 2>/dev/null"

load "../conf/fanplot.gp"
