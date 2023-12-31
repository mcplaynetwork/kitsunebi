#!/bin/bash

# if [ $# -lt 1 ]; then
#   echo "Usage: $0 <password>"
#   exit 1
# fi

dist_server="infra@10.210.6.1"
dest_base_dir="$HOME/kitsunebi/data"
source_base_dir="~/dist/kitsunebi"

if [ ! -d "$dest_base_dir" ]; then
  echo "Error: Destination base directory '$dest_base_dir' does not exist."
  exit 1
fi

for dest_dir in "$dest_base_dir"/*; do
  if [ ! -d "$dest_dir" ]; then
    echo "Error: Destination directory '$dest_dir' does not exist."
    exit 1
  fi
  dir_name=$(basename "$dest_dir")
  dest_dir="$dest_base_dir/$dir_name"
  source_dir="$source_base_dir/$dir_name"

  sshpass -p "$ADMIN_PASSWORD" rsync -av --delete --exclude='*/' --include='*.jar' --include='list.txt' "$dist_server:$source_dir/" "$dest_dir/plugins/"

  if [ $? -eq 0 ]; then
    echo "Success: Jar files from '$dir_name' copied successfully."
  else
    echo "Error: An error occurred while copying jar files from '$dir_name'."
  fi
done
