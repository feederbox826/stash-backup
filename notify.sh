#!/usr/bin/env bash

notify() {
    # notify_discord "$@"
    return 0
}

notify_discord() {
    content="Backup complete - diff: $2 with size $3"
    curl -X POST -H "Content-Type: application/json" -d "{
        \"content\": \"$content\",
        \"username\": \"stash-backup\"
    }" "$DISCORD_WEBHOOK"
}