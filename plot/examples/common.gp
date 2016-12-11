#
# common.gp - common setttings for all gen*.gp
#

# plot settings
#
set style data points

# frame settings
#
set lmargin 12
set key top left
set grid

# x-axis is for date/time
#
set xdata time
set timefmt "%Y/%m/%d %H:%M"
set format x "%H:%M\n%m/%d\n%Y"

# settings for SVG output
#
set terminal svg size 1000,500 background rgb "#000000"
set grid   linecolor rgb "white"
set border linecolor rgb "white"
set key    textcolor rgb "white"
set title  textcolor rgb "white"
set xlabel textcolor rgb "white"
set ylabel textcolor rgb "white"
output_ext=".svg"
output_fname(f)=sprintf("%s%s", f, output_ext)

# settings for GIF output
# (invert color spec by using NetPBM)
#
# set terminal pbm color
# output_ext=".gif"
# output_fname(fbase)=sprintf("|../bin/pnminvert|../bin/ppmtogif >%s%s 2>/dev/null", fbase, output_ext)
