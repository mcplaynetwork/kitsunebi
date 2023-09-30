#!/bin/bash

DIST_DIR="$HOME/kitsune-core/dist"

for repo_dir in "$DIST_DIR"/*; do
    if [ -d "$repo_dir" ]; then
        repo_name=$(basename "$repo_dir")

        echo "Creating file list for $repo_name..."

        files=$(find "$repo_dir" -maxdepth 1 -type f -name "*.jar" -exec basename {} \;)

        if [ -n "$files" ]; then
            echo "$files" > "$repo_dir/list.txt"
        fi
    fi
done

echo "Created file lists for each subdirectory."
