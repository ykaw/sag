#  shconf.sh  -  shell variable configuration for SAG
#
#  $Id: shconf.sh,v 1.3 2021/10/04 15:22:35 kaw Exp $

# categories to process data
#
targets='0001la 0001net 0005mem 0100df 0100time 0005timeofs'

# days to store data
#
rotate_max=64

# days to display graph
#
     span_la=8
    span_net=8
    span_mem=8
     span_df=32
   span_time=32
span_timeofs=8
