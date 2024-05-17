#!/usr/bin/env bash

# Shared utility functions

readFileName() {
    filename=$1
    # first split out `./` if it eixsts
    if [[ $filename == ./* ]]; then
        filename=${filename:2}
    fi
    # split out the rest of the path
    # shellcheck disable=SC2034
    IFS='.' read -r basename sqlite schema datetime type filetype <<<"$filename"
    IFS='_' read -r date time <<<"$datetime"
    echo "$schema $date $time $type"
}