#!/usr/bin/env bash

validate() {
    if [ -z "$STASH_URL" ] || [ -z "$STASH_APIKEY" ]; then
        echo "STASH_URL and STASH_APIKEY must be set"
        exit 1
    fi
}

load_performers() {
    mkdir -p backup/performers && cd backup/performers || exit
    # load performers
    all_performers=$(wget \
        --header="Content-Type: application/json" \
        --header="ApiKey: $STASH_APIKEY" \
        --post-data='{"query":"query { allPerformers { image_path name id }}"}' \
        --no-check-certificate \
        -qO - "$STASH_URL")
    echo "$all_performers" >> "$(date +%Y%m%d_%H%M%S)".performers.json
    echo "Downloaded performers json"
    echo "$all_performers" | jq -r '.data.allPerformers[].image_path' | download_img
    cd - > /dev/null || exit
}

load_tags() {
    mkdir -p backup/tags && cd backup/tags || exit
    # load tags
    all_tags=$(wget \
        --header="Content-Type: application/json" \
        --header="ApiKey: $STASH_APIKEY" \
        --post-data='{"query":"query { allTags { image_path name id }}"}' \
        --no-check-certificate \
        -qO - "$STASH_URL")
    echo "$all_tags" >> "$(date +%Y%m%d_%H%M%S)".tags.json
    echo "Downloaded tags json"
    echo "$all_tags" | jq -r '.data.allTags[].image_path' | download_img
    cd - > /dev/null || exit
}

download_img() {
    wget \
        --header="Content-Type: application/json" \
        --header="ApiKey: $STASH_APIKEY" \
        --content-disposition \
        --no-check-certificate \
        --show-progress \
        -x -nv -nc -i -
}

validate
echo "Downloading tag images..."
load_tags
echo "Downloading performer images..."
load_performers