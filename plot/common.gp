set xdata time
set timefmt "%Y/%m/%d %H:%M"
set format x "%m/%d\n%H:%M"
set xlabel ""
set style data points
set lmargin 12

# settings for SVG output
#
# set rmargin 20
# set grid   linecolor rgb "white"
# set border linecolor rgb "white"
# set key top right out textcolor rgb "white"
# set title  "" textcolor rgb "white"
# set xlabel "" textcolor rgb "white"
# set ylabel "" textcolor rgb "white"
# set terminal svg size 1000,500 background rgb "#000000"
# output_ext=".svg"
# output_fname(f)=sprintf("%s%s", f, output_ext)

# settings for GIF output
#
set grid
set key top left
set terminal pbm color
output_ext=".gif"
output_fname(fbase)=sprintf("|../bin/pnminvert|../bin/ppmtogif >%s%s 2>/dev/null", fbase, output_ext)
