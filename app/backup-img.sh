#!/usr/bin/env bash

source stashapp.sh

validate() {
    if [ -z "$STASH_URL" ] || [ -z "$STASH_APIKEY" ]; then
        echo "STASH_URL and STASH_APIKEY must be set"
        exit 1
    fi
}

load_performers() {
    mkdir -p backup/performers && cd backup/performers || exit
    # load performers
    all_performers=$(stash_gql "query { allPerformers { image_path name id }}")
    echo "$all_performers" >> "$(date +%Y%m%d_%H%M%S)".performers.json
    echo "Downloaded performers json"
    echo "$all_performers" | jq -r '.data.allPerformers[].image_path' | stash_file
    cd - > /dev/null || exit
}

load_tags() {
    mkdir -p backup/tags && cd backup/tags || exit
    # load tags
    all_tags=$(stash_gql "query { allTags { image_path name id }}")
    echo "$all_tags" >> "$(date +%Y%m%d_%H%M%S)".tags.json
    echo "Downloaded tags json"
    echo "$all_tags" | jq -r '.data.allTags[].image_path' | stash_file
    cd - > /dev/null || exit
}

validate
echo "Downloading tag images..."
load_tags
echo "Downloading performer images..."
load_performers