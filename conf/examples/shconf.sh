#  shconf.sh  -  shell variable configuration for SAG
#
#  $Id: shconf.sh,v 1.2 2017/01/07 06:10:54 kaw Exp $

# categories to process data
#
targets='0001la 0001net 0005mem 0100df 0100time 0005timeofs'

# days to store data
#
rotate_max=750

# days to display graph
#
     span_la=15
    span_net=15
    span_mem=15
     span_df=375
   span_time=375
span_timeofs=15
