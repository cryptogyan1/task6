#!/bin/bash

SCRIPT="./run_rl_swarm.sh"
LOGFILE="watchdog.log"
RETRY_DELAY=10
CRASH_COUNT=0
WAITING_LIMIT=3

while true; do
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$TIMESTAMP] Starting RL swarm script..." >> "$LOGFILE"

    WAITING_COUNT=0

    # Start the script in a subshell and capture PID
    bash "$SCRIPT" | while IFS= read -r line; do
        echo "$line" >> "$LOGFILE"

        if [[ "$line" == *"Waiting for modal userData.json to be created..."* ]]; then
            WAITING_COUNT=$((WAITING_COUNT + 1))
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] Detected waiting message ($WAITING_COUNT times)" >> "$LOGFILE"
            if [ "$WAITING_COUNT" -gt $WAITING_LIMIT ]; then
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] Exceeded waiting message limit. Killing and restarting script..." >> "$LOGFILE"
                pkill -f "$SCRIPT"  # Kill the script
                break  # Break the pipe to restart
            fi
        fi
    done

    EXIT_CODE=$?

    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    if [ $EXIT_CODE -eq 0 ]; then
        echo "[$TIMESTAMP] RL Swarm node exited successfully with code 0." >> "$LOGFILE"
    else
        CRASH_COUNT=$((CRASH_COUNT + 1))
        echo "[$TIMESTAMP] Crash #$CRASH_COUNT - Exit code $EXIT_CODE. Restarting in ${RETRY_DELAY}s..." >> "$LOGFILE"
    fi

    sleep $RETRY_DELAY
done
