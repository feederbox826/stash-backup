#!/usr/bin/env bash

# load environment variables
# shellcheck source=/dev/null
source .env.sh
source upload.sh
source notify.sh

# trigger backup from GQL
download() {
    download_url=$(curl -s \
    -X POST \
    -H "Content-Type: application/json" \
    -H "ApiKey: $STASH_APIKEY" \
    -d '{"query":"mutation backup { backupDatabase(input: { download: true }) }"}' "$STASH_URL" \
    | jq -r '.data.backupDatabase')
    # download backup
    filename=$(basename "$download_url")
    filename+=".full.sqlite"
    curl -sLo "$filename" \
        -H "ApiKey: $STASH_APIKEY" \
        "$download_url"
    echo "$filename"
}

process_backup() {
    # cd to backup subdir
    mkdir -p backup && cd backup || exit
    # set up directory
    basedir=$(date +%Y/%m)
    mkdir -p "$basedir" && cd "$basedir" || exit

    # find full backup file
    lastfile=$(find . -type f -mtime -7 -name "*.full.sqlite" | head -n1)
    # if no lastfile, just download and exit
    if [ -z "$lastfile" ]; then
        download
        if $NOTIFY_ENABLED; then
            file_size="$(du -h "$filename" | cut -f1)"
            notify "$filename" false "$file_size"
        fi
        return
    fi
    # check new file
    old_schema="$(echo "$lastfile" | cut -d'.' -f4)"
    old_date="$(echo "$lastfile" | cut -d'.' -f5 | cut -d'_' -f1 | date +%s -f -)"

    filename=$(download)
    new_schema="$(echo "$filename" | cut -d'.' -f3)"
    # only process if schema is same and date is not greater than 7 days
    outdated_date=$(date +%s --date="-7 days")
    if (( new_schema == old_schema )) && (( old_date > outdated_date)); then
        sqldiff --primarykey "$lastfile" "$filename" > "$filename.diff.sql"
        rm "$filename"
        DIFF_SIZE="$(du -h "$filename.diff.sql" | cut -f1)"
        if $NOTIFY_ENABLED; then
            notify "$filename.diff.sql" true "$DIFF_SIZE"
        fi
    fi
}

process_backup
# upload with tool
if $UPLOAD_ENABLED; then
    upload
fi