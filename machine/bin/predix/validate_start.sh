#!/bin/sh

# Copyright (c) 2012-2016 General Electric Company. All rights reserved.
# The copyright to the computer software herein is the property of
# General Electric Company. The software may be used and/or copied only
# with the written permission of General Electric Company or in accordance
# with the terms and conditions stipulated in the agreement/contract
# under which the software has been supplied

writeConsoleLog () {
    echo "$(date +"%m/%d/%y %H:%M:%S") $1"
    if [ "x$START_PREDIX_MACHINE_LOG" != "x" ]; then
       echo "$(date +"%m/%d/%y %H:%M:%S") $1" >> "$START_PREDIX_MACHINE_LOG"
    fi
}

DIRNAME=`dirname "$0"`
PREDIX_MACHINE_HOME=`cd "$DIRNAME/../../.."; pwd`
PREDIX_MACHINE_DATA=${PREDIX_MACHINE_DATA_DIR-$PREDIX_MACHINE_HOME}
START_PREDIX_MACHINE_LOG=$PREDIX_MACHINE_DATA/logs/machine/start_predixmachine.log
JAVA_VERSION=$(java -version 2>&1 | sed -n ';s/.* version "\(.*\)\.\(.*\)\..*"/\1\2/p;')
JAVA_MIN_VERSION=18

# Some Linux systems have been known to have Java in the path, but not keytool,
# which may be accessible via $JAVA_HOME. This function adds $JAVA_HOME/bin to path
# if indeed keytool is not in path but is under $JAVA_HOME.
locate_keytool()
{
    command -v keytool >/dev/null 2>&1  &&  {
        return 0;
    }

    command -v ${JAVA_HOME}/bin/keytool >/dev/null 2>&1  && {
        export PATH=$PATH:${JAVA_HOME}/bin
        return 0;
    }
    return 1;
}

# Exit if keytool is not installed.
if ! locate_keytool; then
	writeConsoleLog "Java keytool not found.  Exiting."
	exit 1
fi

# Exit if incorrect Java installation
if [ -x "$JAVA_HOME/bin/java" ]; then
        JAVA_VERSION=$($JAVA_HOME/bin/java -version 2>&1 | sed -n ';s/.* version "\(.*\)\.\(.*\)\..*"/\1\2/p;')
fi
if [ $JAVA_VERSION -lt $JAVA_MIN_VERSION ]; then
	writeConsoleLog "Java version out of date.  Exiting."
	exit 1
fi

# Check if a lock file currently exists
if [ ! -n "${PREDIXMACHINELOCK+1}" ]; then
    PREDIXMACHINELOCK=$PREDIX_MACHINE_HOME/security
fi
if [ -f "$PREDIXMACHINELOCK/lock" ]; then
  # Get the PID of the start container script
  start_container_pid=$(cat $PREDIXMACHINELOCK/lock)
  # Get the PID of the associated Predix Machine java OSGI container child process
  init_pmpid=$(pgrep -P $start_container_pid)
  # Make sure the PID is the OSGI container
  pmpid=$(ps ax | grep -E "${init_pmpid}.*com.prosyst.mbs.impl.framework.Start" | grep -v grep | awk '{print $1}')
  # Check if Predix Machine process is running
  kill -s 0 $pmpid 2> /dev/null
  process_dead=$?
  if [ $process_dead -eq 0 ]; then
    writeConsoleLog "Another instance of Predix Machine associated with this container is currently running."
    exit 1
  else
    # Remove the lock as it is not associated with a running Predix Machine process
    rm -vf $PREDIXMACHINELOCK/lock >> "$START_PREDIX_MACHINE_LOG"
  fi
fi
