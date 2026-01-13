#!/usr/bin/env bash

notify() {
    notify_stdout "$@"
    if ! $NOTIFY_ENABLED; then
        return 0
    fi
    # notify_discord "$@"
}

notify_stdout() {
    filename=$1
    diff=$2
    size=$3
    if $diff; then
        echo "Backup complete - diff $filename with size $size"
    else
        echo "Backup complete - full backup $filename with size $size"
    fi
}

notify_discord() {
    content="Backup complete - diff: $2 with size $3"
    wget -qO- --post-data "{
        \"content\": \"$content\",
        \"username\": \"stash-backup\"
    }" "$DISCORD_WEBHOOK"
}