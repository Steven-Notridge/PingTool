#!/bin/bash
# Configured to run in K3S Pods. 

# This line will ensure cronjob checks here for the log file.
cd "$(dirname "$0")";
FILE=log.txt
TARGET=1.1.1.1
ROUTER=192.168.0.1

# Change these to your own IPs and the Gotify APP Token.
GOTIFY=192.168.0.51
TOKEN=AUMsXTvBKrEKNGr

if [[ -f "$FILE" ]]; then
        echo "$FILE exists. Continuing..."
        else
        echo "$FILE doesn't exist. Creating file..."
        touch $FILE
        fi
        
    DATE=$(date '+%d/%m/%Y %H:%M')

    # Ping once, see if the connection is alive.
    ping -c 1 $TARGET &> /dev/null
    # If ping does not connect, as this returns a boolean value. 0 means false. 1 means true.
    if [[ $? -ne 0 ]]; then
            echo >> $FILE
            echo "["$DATE"]" "Ping failure to "$TARGET >> $FILE
            ping -c 1 $ROUTER &> /dev/null
            if [[ $? -ne 0 ]]; then
                echo >> $FILE
                echo "Ping failure to "$ROUTER "Did it restart?" >> $FILE
                    else
                    echo "Connection to Router is alive. Internet appears to be down." >> $FILE
            fi
    fi
    RESULTS=$(ping -c 5 1.1.1.1 | tail -1)
    RESULTSAVG=$(echo $RESULTS | awk -F '/' '{print $5}' | cut -d "." -f 1 )
    RESULTSMAX=$(echo $RESULTS | awk -F '/' '{print $6}' | cut -d "." -f 1 )
if [[ $RESULTSMAX -gt 75 ]]; then
    HIGHPING="Ping is reaching high values. The average response time was $RESULTSAVG ms to $TARGET, whilst the maximum response time was $RESULTSMAX ms."
    echo >> $FILE
    echo "["$DATE"]" "Ping is reaching high values. The average response time was" $RESULTSAVG "ms to "$TARGET", whilst the maximum response time was "$RESULTSMAX >> $FILE
    curl "$GOTIFY/message?token=$TOKEN" -F "title=High Response Time" -F "message=$HIGHPING" -F "priority=5"
    fi
