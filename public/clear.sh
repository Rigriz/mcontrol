bash

#!/bin/bash

# Target strictly the root of your current user profile TARGET DIR="$HOME"

echo "Cleaning the root of user profile: $TARGET_DIR"

#-maxdepth 1: Stays only in the main folder; does not enter subfolders

#-type f: Deletes files only; leaves all folders untouched

#!-name ".*": Explicitly skips hidden files (like .bashrc or .config)

find "STARGET_DIR" -maxdepth 1 -type f! -name ".*"-delete

echo "Cleanup finished. Hidden configurations and folders were safely skipped"