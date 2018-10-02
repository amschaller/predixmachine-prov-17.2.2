#!/bin/bash

# ge-client-down.d -- All scripts owned and managed by GE
# Note - For now there are no GE specific scripts to be run 

# Run all the scripts in ge-client-down.d directory
for SCRIPT in ./ge-client-down.d/*
    do
        if [ -f $SCRIPT -a -x $SCRIPT ]
        then
            echo "EXECUTING ::: " $SCRIPT
            $SCRIPT
        fi
    done

