#  shconf.sh  -  shell variable configuration for SAG
#
#  $Id: shconf.sh,v 1.4 2023/07/28 02:01:07 kaw Exp $

# categories to process data
#
targets='0001la 0001procs 0005mem 0100df 0001net 0005timeofs 0100time'

# days to store data
#
rotate_max=32

# days to display graph
#
     span_la=8
  span_procs=8
    span_mem=8
     span_df=32
    span_net=8
span_timeofs=8
   span_time=32
