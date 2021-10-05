# common.gp - common setttings for all gen*.gp
#
# $Id: common.gp,v 1.5 2021/10/05 00:10:28 kaw Exp $

# plot settings
#
set style data points

# frame settings
#
set key top left
set grid

# x-axis is for date/time
#
set xdata time
set timefmt "%Y/%m/%d %H:%M"
set format x "%H:%M\n%m/%d\n%Y"

# color settings
#
set grid   linecolor rgb "#808080"
set border linecolor rgb "#c0c0c0"
set key    textcolor rgb "#c0c0c0"
set title  textcolor rgb "white"
set xlabel textcolor rgb "white"
set ylabel textcolor rgb "white"

# default output filename format
#
output_fname(f)=sprintf("%s%s", f, output_ext)

#
# settings for various graphic format
#
# Choose one and make it uncommented.

# # SVG
# set terminal svg size 640,480 background rgb "black"
# output_ext=".svg"

# PNG
set terminal png size 640,480 background rgb "black" fontscale 0.7
output_ext=".png"

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
