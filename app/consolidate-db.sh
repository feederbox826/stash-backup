#!/usr/bin/env bash

# Consolidate backups into a single archive with zstd

# shellcheck source=/dev/null
source utils.sh

trap ctrl_c INT
function ctrl_c() {
    exit 1
}

# Consolidate backups into a single archive with zstd
# check if cron schedule is < 1 day
CRON_HOUR=$(cut -d ' ' -f2 <<< "$CRON_SCHEDULE")

tar_consolidate() {
    find . -type f -name "$1" -print0 \
        | tar --remove-files -cf - --null -T - \
        | zstd -19 -T0 --long -q -f -o "$2.tar.zst"
}

consolidate_month() {
    # if current month, ignore
    if [[ $1 == $(date +%Y/%m) ]]; then
        echo "Not consolidating current month"
        return
    fi
    # kinda just ignore everything and tar it all up
    filename=$(date +%Y-%m -d"$1/01")
    tar --remove-files -cf - "$1" \
        | zstd -19 -T0 --long -q -f -o "stash-$filename.tar.zst"
}

consolidate_day() {
    cd "$1" || exit
    # check if folder is this month
    endDate=$(date +%Y%m%d -d "$1/01")
    if [[ $1 == "$(date +%Y/%m)" ]] ; then
        searchDate=$(date +%Y%m%d -d "1 day ago")
    else
        searchDate=$(date +%Y%m%d -d "$1/01 + 1 month - 1 day" )
    fi
    # consolidate older backups
    while [ "$searchDate" != "$endDate" ]; do
        oldFiles=$(find . -type f -name "stash-go.sqlite.*.$searchDate*")
        if [[ -z $oldFiles ]]; then
            echo "no more files"
            break
        fi
        echo "consolidating"
        # shellcheck disable=SC2207
        oldFileInfo=( $(readFileName "$oldFiles") )
        # find all backups from same date with same schema and consolidate
        tar_consolidate "stash-go.sqlite.${oldFileInfo[0]}.${oldFileInfo[1]}*" "stash-${oldFileInfo[0]}.${oldFileInfo[1]}"
        searchDate=$(date +%Y%m%d -d "$searchDate - 1 day")
    done
    cd - || exit
}

pick_consolidation() {
    cd backup || exit
    if [[ $CRON_HOUR == "*" ]]; then
        consolidate_day "$1"
        return
    fi
    consolidate_month "$1"
    cd - || exit
}

run_consolidate() {
    find backup/ -mindepth 2 -type d -print0 | while IFS= read -r -d '' dir; do
        pick_consolidation "${dir#backup/}"
    done
}
run_consolidate