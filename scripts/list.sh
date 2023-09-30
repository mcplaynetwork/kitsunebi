#!/bin/bash

DIST_DIR="$HOME/kitsune-core/dist"

find "$DIST_DIR" -type d | while read -r subdir; do
    files=$(find "$subdir" -maxdepth 1 -type f -name "*.jar" -exec basename {} \;)
    subdir_name=$(basename "$subdir")
    if [ -n "$files" ]; then
        echo "Creating file list for $subdir_name..."
        echo "$files" > "$subdir/list.txt"
    fi
done

echo "Created file lists for each subdirectory."
