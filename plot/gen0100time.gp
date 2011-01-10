set title "KERNEL CLOCK FREQ. OFFSET"

set xdata time
set timefmt "%Y/%m/%d %H"
set format x "%m/%d\n%H:00"

# set yrange [0:100]

set grid
set key bottom left

set terminal pbm color
set output "| ../bin/pnminvert | ../bin/ppmtogif >0100time.gif 2>/dev/null"

plot "sumtmp-0100time" using 1:3 title "freq. offset (ppm)" with steps
