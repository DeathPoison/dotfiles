#!/bin/bash
#
# battery status script
#

BATTERY=/proc/acpi/battery/BAT1

REM_CAP=`grep "^remaining capacity" $BATTERY/state | awk '{ print $3 }'`
FULL_CAP=`grep "^last full capacity" $BATTERY/info | awk '{ print $4 }'`
BATSTATE=`grep "^charging state" $BATTERY/state | awk '{ print $3 }'`

CHARGE=`echo $(( $REM_CAP * 100 / $FULL_CAP ))`

NON='\033[00m'
BLD='\033[01m'
RED='\033[01;31m'
GRN='\033[01;32m'
YEL='\033[01;33m'

COLOUR="$RED"

case "${BATSTATE}" in
   'charged')
   BATSTT="$BLD=$NON"
   ;;
   'charging')
   BATSTT="$BLD+$NON"
   ;;
   'discharging')
   BATSTT="$BLD-$NON"
   ;;
esac

# prevent a charge of more than 100% displaying
if [ "$CHARGE" -gt "99" ]
then
   CHARGE=100
fi

if [ "$CHARGE" -gt "15" ]
then
   COLOUR="$YEL"
fi

if [ "$CHARGE" -gt "30" ]
then
   COLOUR="$GRN"
fi

echo -e "${COLOUR}${CHARGE}%${NON} ${BATSTT}"

# end of file
