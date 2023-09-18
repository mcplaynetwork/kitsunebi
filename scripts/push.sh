#!/bin/bash

data_dir="$HOME/data"

for repo_dir in $HOME/data/*; do
  if [ -d "$repo_dir/.git" ]; then
    echo "Processing Git repository in: $repo_dir"
    cd "$repo_dir" || exit 1

    git push

    echo "Completed pushing changes to repository in: $repo_dir"
  fi
done
