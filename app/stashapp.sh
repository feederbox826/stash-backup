#!/usr/bin/env bash

stash_gql() {
  query=$1
  wget \
    --header="Content-Type: application/json" \
    --header="ApiKey: $STASH_APIKEY" \
    --post-data="{\"query\":\"$query\"}" \
    -qO - "$STASH_URL"
}

stash_dump() {
  wget \
    --header="ApiKey: $STASH_APIKEY" \
    -qO "$1" "$2"
}

stash_file() {
  wget \
    --header="ApiKey: $STASH_APIKEY" \
    -x -q -nc -i -
}