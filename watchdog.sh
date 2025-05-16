#!/bin/bash

SCRIPT="./run.sh"
LOGFILE="watchdog.log"
RETRY_DELAY=10
CRASH_COUNT=0

while true; do
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$TIMESTAMP] Starting RL swarm script..." >> "$LOGFILE"

    # Run script in foreground
    bash "$SCRIPT"
    EXIT_CODE=$?

    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    if [ $EXIT_CODE -eq 0 ]; then
        # Normal exit
        echo "[$TIMESTAMP] RL Swarm node exited successfully with code 0." >> "$LOGFILE"
    else
        # Crash detected
        CRASH_COUNT=$((CRASH_COUNT + 1))
        echo "[$TIMESTAMP] Crash #$CRASH_COUNT - Exit code $EXIT_CODE. Restarting in ${RETRY_DELAY}s..." >> "$LOGFILE"
    fi

    sleep $RETRY_DELAY
done
