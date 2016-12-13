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

# color settings
#
set grid   linecolor rgb "white"
set border linecolor rgb "white"
set key    textcolor rgb "white"
set title  textcolor rgb "white"
set xlabel textcolor rgb "white"
set ylabel textcolor rgb "white"

# default output filename format
#
output_fname(f)=sprintf("%s%s", f, output_ext)

#
# settings for various graphic format
#

# SVG
set terminal svg size 640,480 background rgb "black"
output_ext=".svg"

# # PNG
# set terminal png size 640,480 background rgb "black" fontscale 0.7
# output_ext=".png"

# GIF
# set terminal gif size 640,480 background rgb "black" fontscale 0.7
# output_ext=".gif"

# GIF (invert color spec by using NetPBM)
#
# set terminal pbm color
# output_ext=".gif"
# output_fname(fbase)=sprintf("|../bin/pnminvert|../bin/ppmtogif >%s%s 2>/dev/null", fbase, output_ext)

# Text
# set terminal dumb size 80,24
# output_ext=".txt"
