#!/bin/bash

USER_HOME="$HOME"

echo "Cleaning user files from: $USER_HOME"

find "$USER_HOME" -mindepth 1 -maxdepth 1 | while read item; do
    BASENAME=$(basename "$item")

    # Skip hidden metadata/config folders
    if [[ "$BASENAME" == .* ]]; then
        continue
    fi

    rm -rf "$item"
done

echo "Cleanup completed."
