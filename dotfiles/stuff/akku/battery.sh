#!/bin/bash
BATTERY=/sys/class/power_supply/BAT0

#REM_CAP=`cat $BATTERY/energy_now`
#FULL_CAP=`cat $BATTERY/energy_full`
BATSTATE=`cat $BATTERY/status`

CHARGE="$(acpi | cut -d, -f2 | sed 's/.\{1\}$//' | sed 's/^.\{,1\}//')"
#CHARGE=`$(( 100*$REM_CAP / $FULL_CAP ))`

NON='\033[00m'
BLD='\033[01m'
RED='\033[01;31m'
GRN='\033[01;32m'
YEL='\033[01;33m'

COLOUR="$RED"

case "${BATSTATE}" in
   'Charged')
   BATSTT="$BLD=$NON"
   ;;
   'Charging')
   BATSTT="$BLD+$NON"
   ;;
   'Discharging')
   BATSTT="$BLD-$NON"
   ;;
esac

if [[ "$CHARGE" -gt 99 ]]
then
	CHARGE="100"
fi

if [[ "$CHARGE" -gt 30 ]]
then
	COLOUR="$GRN"
fi

if [[ "$CHARGE" -gt 15 ]]
then
	COLOUR="$YEL"
fi


echo -e "${COLOUR}${CHARGE}%${NON} ${BATSTT}"
