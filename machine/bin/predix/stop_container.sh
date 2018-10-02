#!/bin/sh
# Copyright (c) 2012-2016 General Electric Company. All rights reserved.
# The copyright to the computer software herein is the property of
# General Electric Company. The software may be used and/or copied only
# with the written permission of General Electric Company or in accordance
# with the terms and conditions stipulated in the agreement/contract
# under which the software has been supplied.

cd "$(dirname "$0")/../../.."
PREDIX_MACHINE_HOME=$(pwd)
PREDIX_MACHINE_DATA=${PREDIX_MACHINE_DATA_DIR-$PREDIX_MACHINE_HOME}
START_PREDIX_MACHINE_LOG=$PREDIX_MACHINE_DATA/logs/machine/start_predixmachine.log

# This function takes a string value, creates a timestamp, and writes it the log file as well as the console
writeConsoleLog () {
    echo "$(date +"%m/%d/%y %H:%M:%S") $1"
    if [ "x$START_PREDIX_MACHINE_LOG" != "x" ]; then
       echo "$(date +"%m/%d/%y %H:%M:%S") $1" >> "$START_PREDIX_MACHINE_LOG"
    fi
}

# Check the environment for the PREDIXMACHINELOCK variable.  If not set use the security directory.
if [ ! -n "${PREDIXMACHINELOCK+1}" ]; then
    PREDIXMACHINELOCK=$PREDIX_MACHINE_DATA/security
fi
if [ ! -f "$PREDIXMACHINELOCK/lock" ]; then
	writeConsoleLog "Lock file doesn't exist. No Predix Machine process is associated with this stop script."
  exit 1
fi

start_container_pid=$(cat "$PREDIXMACHINELOCK/lock")
init_pmpid=$(pgrep -P $start_container_pid)

writeConsoleLog "Terminating Predix Machine process."
pmpid=$(ps ax | grep -E "${init_pmpid}.*com.prosyst.mbs.impl.framework.Start" | grep -v grep | awk '{print $1}')
if [ "x$pmpid" != "x" ]; then
	kill -TERM $pmpid
else
	writeConsoleLog "No Predix Machine process is associated with this stop script was found to be running."
  rm -vf $PREDIXMACHINELOCK/lock >> "$START_PREDIX_MACHINE_LOG"
  exit 1
fi

SHUTDOWNCHECKCNT=1
while true; do
  kill -s 0 $pmpid 2> /dev/null
  process_dead=$?
	if [ "$SHUTDOWNCHECKCNT" -ge 180 ]; then
		writeConsoleLog "Error: Framework shutdown took longer than 3 minutes."
		exit 1
  elif [ $process_dead -eq 0 ]; then
		sleep 1
		SHUTDOWNCHECKCNT=$((SHUTDOWNCHECKCNT+1))
	else
		writeConsoleLog "Framework has shutdown."
		exit 0
	fi
done
