#!/bin/bash

data_dir="$HOME/data"

for repo_dir in $data_dir/*; do
  if [ -d "$repo_dir/.git" ]; then
    echo "Processing Git repository in: $repo_dir"
    cd "$repo_dir" || exit 1

    git add .
    git commit -m "kitsunebi: `date +'%Y-%m-%d %H:%M:%S'`" -m "`git diff --name-only --staged`"

    echo "Completed processing repository in: $repo_dir"
  fi
done
