#!/bin/bash
# Uses sudo apt install inotify-tools

WATCH_DIR="/$HOME/Documents"
SYNCTO="myremote:mysyncshare"
RCLONE_LOG="$HOME/_detect-sync.log"
EVENT_LOG="$HOME/_detect-events.log"
DELAY=60

inotifywait -m -r -e modify,create,delete,move \
    --format '%T | %e | %w%f' --timefmt '%Y-%m-%d %H:%M:%S' "$WATCH_DIR" |
while read -r line; do
    # Log the detected event (already timestamped by inotifywait)
    echo "$line" >> "$EVENT_LOG"
    echo "$(date '+%Y-%m-%d %H:%M:%S') | Change detected, waiting ${DELAY}s for more..." >> "$EVENT_LOG"

    # In the next 60 seconds, keep reading and discarding new events.
    # Also log them so you can see what was absorbed during the wait.
    timeout "$DELAY" cat |
    while read -r absorbed; do
        echo "$absorbed" >> "$EVENT_LOG"
    done

    # After timeout ends, the directory has been quiet for 60 seconds
    echo "$(date '+%Y-%m-%d %H:%M:%S') | Syncing now..." >> "$EVENT_LOG"
    rclone sync "$WATCH_DIR" $SYNCTO --log-file="$RCLONE_LOG" --log-level INFO
done
