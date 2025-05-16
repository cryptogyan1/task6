#!/bin/bash

SCRIPT="./run.sh"
LOGFILE="watchdog.log"
RETRY_DELAY=10
CRASH_COUNT=0
WAITING_LIMIT=5
MESSAGE_WINDOW=60  # seconds to allow the message to appear before triggering

while true; do
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$TIMESTAMP] Starting RL swarm script..." >> "$LOGFILE"

    WAITING_COUNT=0
    LAST_WAIT_TS=0

    # Start run.sh and monitor its output
    bash "$SCRIPT" | while IFS= read -r line; do
        echo "$line" >> "$LOGFILE"

        if [[ "$line" == *"Waiting for API key to be activated..."* ]]; then
            NOW_TS=$(date +%s)

            if (( LAST_WAIT_TS == 0 || NOW_TS - LAST_WAIT_TS > MESSAGE_WINDOW )); then
                WAITING_COUNT=1
            else
                WAITING_COUNT=$((WAITING_COUNT + 1))
            fi

            LAST_WAIT_TS=$NOW_TS

            echo "[$(date '+%Y-%m-%d %H:%M:%S')] API wait message seen $WAITING_COUNT times..." >> "$LOGFILE"

            if [ "$WAITING_COUNT" -gt "$WAITING_LIMIT" ]; then
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] Too many API wait messages. Restarting..." >> "$LOGFILE"
                pkill -f "$SCRIPT"
                break
            fi
        fi
    done

    EXIT_CODE=$?
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    if [ $EXIT_CODE -eq 0 ]; then
        echo "[$TIMESTAMP] RL Swarm node exited normally (code 0)." >> "$LOGFILE"
    else
        CRASH_COUNT=$((CRASH_COUNT + 1))
        echo "[$TIMESTAMP] Crash #$CRASH_COUNT - Exit code $EXIT_CODE. Restarting in $RETRY_DELAY s..." >> "$LOGFILE"
    fi

    sleep $RETRY_DELAY
done
