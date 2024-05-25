#!/usr/bin/env bash

# load environment variables
# shellcheck source=/dev/null
# shellcheck disable=SC2046
[ ! -f .env ] || export $(xargs <.env)
source upload.sh
source notify.sh
source utils.sh

trap ctrl_c INT
function ctrl_c() {
    exit 1
}

set -e

validate() {
    if [ -z "$STASH_URL" ] || [ -z "$STASH_APIKEY" ]; then
        echo "STASH_URL and STASH_APIKEY must be set"
        exit 1
    fi
}

# trigger backup from GQL
download() {
    download_url=$(wget \
        --header="Content-Type: application/json" \
        --header="ApiKey: $STASH_APIKEY" \
        --post-data='{"query":"mutation backup { backupDatabase(input: { download: true }) }"}' \
        --no-check-certificate \
        -qO - "$STASH_URL" \
        | jq -r '.data.backupDatabase')
    # download backup
    filename=$(basename "$download_url")
    wget \
        --header="ApiKey: $STASH_APIKEY" \
        --no-check-certificate \
        -qO "$filename" "$download_url"
    echo "$filename"
}

full_backup() {
        mv "$filename" "$filename.full.sqlite"
        filename="$filename.full.sqlite"
        file_size="$(du -bhL "$filename" | cut -f1)"
        notify "$filename" false "$file_size"
    }

process_backup() {
    # cd to backup/db subdir
    mkdir -p backup/db && cd backup/db || exit
    # set up directory
    basedir=$(date +%Y/%m)
    mkdir -p "$basedir" && cd "$basedir" || exit

    # find full backup file
    lastfile=$(find . -type f -mtime -7 -name "*.full.sqlite" | sort | tail -n1)
    # if no lastfile, just download and exit
    if [[ ! -f "$lastfile" ]]; then
        filename=$(download)
        full_backup
        return
    fi
    # check new file
    # shellcheck disable=SC2207
    oldFileInfo=( $(readFileName "$lastfile") )
    old_date="$(date +%s --date "${oldFileInfo[1]}")"

    filename=$(download)
    # shellcheck disable=SC2207
    newFileInfo=( $(readFileName "$filename") )

    # only process if schema is same and date is not greater than 7 days
    outdated_date=$(date +%s --date="-7 days")
    if (( newFileInfo[0] != oldFileInfo[0] )) || (( old_date < outdated_date)); then
        full_backup
        return
    fi
    # partial backup
    sqldiff --primarykey "$lastfile" "$filename" > "$filename.diff.sql"
    # check size of diff
    if [ "$( wc -l < "$filename.diff.sql")" -gt 200 ]; then
        echo "> 200 changes, making full backup"
        rm "$filename.diff.sql"
        full_backup
        return
    else
        rm "$filename"
        diff_size="$(du -bhL "$filename.diff.sql" | cut -f1)"
        notify "$filename.diff.sql" true "$diff_size"
    fi
    cd - > /dev/null || exit
}

validate
# do full backup if requested
if [ "$1" == "full" ]; then
    full_backup
    exit
fi
process_backup
# upload with tool
if $UPLOAD_ENABLED; then
    upload
fi