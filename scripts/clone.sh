#!/bin/bash

if [ $# -eq 0 ]; then
  echo "Error: Please provide the repository name as the first argument."
  exit 1
fi

repo_name="$1"
data_dir="$HOME/data"
repo_url="git@github.com:mcplay-data/$repo_name.git"

mkdir -p "$data_dir"

git clone "$repo_url" "$data_dir/$repo_name"

if [ $? -eq 0 ]; then
  echo "Success: Cloned $repo_name"
else
  echo "Error: Failed to clone $repo_name"
fi
