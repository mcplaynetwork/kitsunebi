#!/bin/bash

repo_list_file="repos.txt"
clone_dir="$HOME/data"

mkdir -p "$clone_dir"

while IFS= read -r repo_name; do
  repo_url="git@github.com:mcplay-data/$repo_name.git"

  git clone "$repo_url" "$clone_dir/$repo_name"

  if [ $? -eq 0 ]; then
    echo "Success: Cloned $repo_name"
  else
    echo "Error: Failed to clone $repo_name"
  fi
done < "$repo_list_file"
