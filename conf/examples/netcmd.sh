# a command line to get i/f name, send/receive bytes
# then print them out
#
# this command will eval-ed by $SAGHOME/bin/t0001
#
# $Id: netcmd.sh,v 1.2 2017/01/07 06:10:54 kaw Exp $

netcmd='set `netstat -I bce0 -b -n -i`; echo $7 ${11} ${12}'
