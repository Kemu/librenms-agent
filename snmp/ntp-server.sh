#!/bin/sh
# Please make sure the paths below are correct.
# Alternatively you can put them in $0.conf, meaning if you've named
# this script ntp-client.sh then it must go in ntp-client.sh.conf .
BIN_NTPD='/usr/bin/env ntpd'
BIN_NTPQ='/usr/bin/env ntpq'
BIN_NTPDC='/usr/bin/env ntpdc'
BIN_GREP='/usr/bin/env grep'
BIN_TR='/usr/bin/env tr'
BIN_CUT='/usr/bin/env cut'
BIN_SED="/usr/bin/env sed"
BIN_AWK='/usr/bin/env awk'
################################################################
# Don't change anything unless you know what are you doing     #
################################################################
CONFIG=$0".conf"
if [ -f $CONFIG ]; then
    . $CONFIG
fi
VERSION=2

NTPQ_RAW=`$BIN_NTPQ -c rv | $BIN_TR ',' '\n' | $BIN_AWK '{$1=$1};1'`
OFFSET=`echo $NTPQ_RAW | $BIN_GREP -oP '(?<=offset=).\S*'`
STRATUM=`echo $NTPQ_RAW | $BIN_GREP -oP '(?<=stratum=).\S*'`
FREQUENCY=`echo $NTPQ_RAW | $BIN_GREP -oP '(?<=frequency=).\S*'`
SYS_JITTER=`echo $NTPQ_RAW | $BIN_GREP -oP '(?<=sys_jitter=).\S*'`
CLK_JITTER=`echo $NTPQ_RAW | $BIN_GREP -oP '(?<=clk_jitter=).\S*'`
CLK_WANDER=`echo $NTPQ_RAW | $BIN_GREP -oP '(?<=clk_wander=).\S*'`

VER=`$BIN_NTPD --version`
if [ "$VER" = '4.2.6p5' ]; then
  USECMD=`echo $BIN_NTPDC -c iostats`
else
  USECMD=`echo $BIN_NTPQ -c iostats localhost`
fi
CMD2=`$USECMD | $BIN_TR -d ' ' | $BIN_CUT -d : -f 2 | $BIN_TR '\n' ' '`

TIMESINCERESET=`echo $CMD2 | $BIN_AWK -F ' ' '{print $1}'`
RECEIVEDBUFFERS=`echo $CMD2 | $BIN_AWK -F ' ' '{print $2}'`
FREERECEIVEBUFFERS=`echo $CMD2 | $BIN_AWK -F ' ' '{print $3}'`
USEDRECEIVEBUFFERS=`echo $CMD2 | $BIN_AWK -F ' ' '{print $4}'`
LOWWATERREFILLS=`echo $CMD2 | $BIN_AWK -F ' ' '{print $5}'`
DROPPEDPACKETS=`echo $CMD2 | $BIN_AWK -F ' ' '{print $6}'`
IGNOREDPACKETS=`echo $CMD2 | $BIN_AWK -F ' ' '{print $7}'`
RECEIVEDPACKETS=`echo $CMD2 | $BIN_AWK -F ' ' '{print $8}'`
PACKETSSENT=`echo $CMD2 | $BIN_AWK -F ' ' '{print $9}'`
PACKETSENDFAILURES=`echo $CMD2 | $BIN_AWK -F ' ' '{print $10}'`
INPUTWAKEUPS=`echo $CMD2 | $BIN_AWK -F ' ' '{print $11}'`
USEFULINPUTWAKEUPS=`echo $CMD2 | $BIN_AWK -F ' ' '{print $12}'`

echo '{"data":{"offset":"'$OFFSET\
'","frequency":"'$FREQUENCY\
'","sys_jitter":"'$SYS_JITTER\
'","clk_jitter":"'$CLK_JITTER\
'","clk_wander":"'$CLK_WANDER\
'","stratum":"'$STRATUM\
'","time_since_reset":"'$TIMESINCERESET\
'","receive_buffers":"'$RECEIVEDBUFFERS\
'","free_receive_buffers":"'$FREERECEIVEBUFFERS\
'","used_receive_buffers":"'$USEDRECEIVEBUFFERS\
'","low_water_refills":"'$LOWWATERREFILLS\
'","dropped_packets":"'$DROPPEDPACKETS\
'","ignored_packets":"'$IGNOREDPACKETS\
'","received_packets":"'$RECEIVEDPACKETS\
'","packets_sent":"'$PACKETSSENT\
'","packet_send_failures":"'$PACKETSENDFAILURES\
'","input_wakeups":"'$PACKETSENDFAILURES\
'","useful_input_wakeups":"'$USEFULINPUTWAKEUPS\
'"},"error":"0","errorString":"","version":"'$VERSION'"}'
