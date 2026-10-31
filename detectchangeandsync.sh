#!/bin/bash

inotifywait -m -r -e modify,create,delete,move "/directory/monitored" |
while read -r _ _ _; do
    echo "Change detected, waiting 60s for more..."
    # In the next 60 seconds, keep reading and discarding new events
    timeout 60 cat > /dev/null
    # After timeout ends, the directory has been quiet for 60 seconds
    echo "Syncing now..."
    rclone sync /directory/monitored remote:monitored --log-file=sync.log --log-level INFO
done
