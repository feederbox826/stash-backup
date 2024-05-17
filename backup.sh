#!/usr/bin/env bash

# load environment variables
# shellcheck source=/dev/null
if [[ -f ".env.sh" ]]; then source .env.sh; fi
source upload.sh
source notify.sh

validate() {
    if [ -z "$STASH_URL" ] || [ -z "$STASH_APIKEY" ]; then
        echo "STASH_URL and STASH_APIKEY must be set"
        exit 1
    fi
}

# trigger backup from GQL
download() {
    download_url=$(curl -Ssk \
    -X POST \
    -H "Content-Type: application/json" \
    -H "ApiKey: $STASH_APIKEY" \
    -d '{"query":"mutation backup { backupDatabase(input: { download: true }) }"}' "$STASH_URL" \
    | jq -r '.data.backupDatabase')
    # download backup
    filename=$(basename "$download_url")
    curl -sko "$filename" \
        -H "ApiKey: $STASH_APIKEY" \
        "$download_url"
    echo "$filename"
}

full_backup() {
        mv "$filename" "$filename.full.sqlite"
        filename="$filename.full.sqlite"
        file_size="$(du -bhL "$filename" | cut -f1)"
        notify "$filename" false "$file_size"
    }

process_backup() {
    # cd to backup subdir
    mkdir -p backup && cd backup || exit
    # set up directory
    basedir=$(date +%Y/%m)
    mkdir -p "$basedir" && cd "$basedir" || exit

    # find full backup file
    lastfile=$(find . -type f -mtime -7 -name "*.full.sqlite" | tail -n1)
    # if no lastfile, just download and exit
    if [[ ! -f "$lastfile" ]]; then
        filename=$(download)
        full_backup
        return
    fi
    # check new file
    old_schema="$(echo "$lastfile" | cut -d'.' -f4)"
    old_date="$(echo "$lastfile" | cut -d'.' -f5 | cut -d'_' -f1 | date +%s -f -)"

    filename=$(download)
    new_schema="$(echo "$filename" | cut -d'.' -f3)"
    # only process if schema is same and date is not greater than 7 days
    outdated_date=$(date +%s --date="-7 days")
    if (( new_schema != old_schema )) || (( old_date < outdated_date)); then
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
}

validate
process_backup
# upload with tool
if $UPLOAD_ENABLED; then
    upload
fi