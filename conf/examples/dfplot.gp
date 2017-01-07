# definitions of disk partitions
#
# $Id: dfplot.gp,v 1.2 2017/01/07 06:10:54 kaw Exp $
#
# This file will included from $SAGHOME/plot/gen0100df.gp
# Reconfigure following to fit to the disk layout.

plot "sumtmp-0100df" using 1:3 title "RDROOT", \
     "sumtmp-0100df" using 1:4 title "LIVEMEDIA", \
     "sumtmp-0100df" using 1:5 title "SYSTEM", \
     "sumtmp-0100df" using 1:6 title "WRITABLE"
