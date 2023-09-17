#!/bin/bash

clone_dir="$HOME/data"

if [ ! -d "$clone_dir" ]; then
  echo "Error: Cloned repositories directory '$clone_dir' not found."
  exit 1
fi

for repo_dir in "$clone_dir"/*; do
  if [ -d "$repo_dir" ]; then
    repo_name=$(basename "$repo_dir")

    cd "$repo_dir"

    git pull

    if [ $? -eq 0 ]; then
      echo "Success: Pulled updates for $repo_name"
    else
      echo "Error: Failed to pull updates for $repo_name"
    fi

    cd ..
  fi
done
