#!/bin/bash

USER_HOME="$HOME"

TARGET_DIRS=(
    "$USER_HOME/Downloads"
    "$USER_HOME/Desktop"
    "$USER_HOME/Pictures"
    "$USER_HOME/Documents"
    "$USER_HOME/Music"
    "$USER_HOME/Videos"
)

echo "Starting cleanup in user directories..."

# 1. Clean standard user folders completely
for dir in "${TARGET_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "Cleaning: $dir"
        find "$dir" -mindepth 1 -exec rm -rf {} +
    fi
done

# 2. Clean top-level HOME (non-hidden only)
echo "Cleaning top-level HOME user files/folders..."

find "$USER_HOME" -mindepth 1 -maxdepth 1 -print0 | while IFS= read -r -d '' item; do
    base="$(basename "$item")"

    # Skip hidden/system folders (critical safety rule)
    if [[ "$base" == .* ]]; then
        continue
    fi

    # Skip standard folders since already cleaned above
    case "$base" in
        Downloads|Desktop|Pictures|Documents)
            continue
            ;;
    esac

    rm -rf "$item"
done

echo "Cleanup completed."
