#!/bin/bash

SCRIPT="./run.sh"
LOGFILE="watchdog.log"
RETRY_DELAY=10
CRASH_COUNT=0
WAITING_LIMIT=3

while true; do
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$TIMESTAMP] Starting RL swarm script..." >> "$LOGFILE"

    WAITING_COUNT=0

    # Use process substitution to get actual script PID
    {
        bash "$SCRIPT" &
        SCRIPT_PID=$!

        # Read the script's output line-by-line
        while IFS= read -r line; do
            echo "$line" >> "$LOGFILE"

            if [[ "$line" == *"Waiting for API key to become activated..."* ]]; then
                WAITING_COUNT=$((WAITING_COUNT + 1))
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] Detected API wait message ($WAITING_COUNT times)" >> "$LOGFILE"
                if [ "$WAITING_COUNT" -gt "$WAITING_LIMIT" ]; then
                    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Exceeded wait limit. Sending Ctrl+C to $SCRIPT_PID" >> "$LOGFILE"
                    kill -2 "$SCRIPT_PID"  # Send SIGINT (Ctrl+C)
                    break
                fi
            fi
        done
    } < <(stdbuf -oL bash "$SCRIPT")  # Ensures output is not buffered

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
