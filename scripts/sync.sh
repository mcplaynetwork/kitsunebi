#!/bin/bash

if [ -z "$1" ]; then
  echo "Error: Please specify a directory name."
  exit 1
fi

source "./secrets/hosts.env"

dest_dir="$HOME/data/$1"
source_dir="~/kitsune-hub/dist/$1"
source "./secrets/hosts.env"
dist_server="$HOST_ADMIN_USER@$HOST_ADMIN"

if [ ! -d "$dest_dir" ]; then
  echo "Error: Destination directory '$dest_dir' does not exist."
  exit 1
fi

rsync -av --delete --exclude='*/' --include='*.jar' --include='list.txt' "$dist_server:$source_dir/" "$dest_dir/plugins/"

if [ $? -eq 0 ]; then
  echo "Success: Jar files copied successfully."
else
  echo "Error: An error occurred while copying jar files."
fi
