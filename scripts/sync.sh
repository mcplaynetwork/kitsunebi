#!/bin/bash

# if [ $# -lt 1 ]; then
#   echo "Usage: $0 <password> [directory_name]"
#   exit 1
# fi

source "$HOME/kitsune-core/secrets/users.env"

directory_name="$1"

dist_server="$ADMIN_USER@10.0.50.2"
dest_base_dir="$HOME/data"
source_base_dir="~/kitsune-core/dist"

if [ ! -d "$dest_base_dir" ]; then
  echo "Error: Destination base directory '$dest_base_dir' does not exist."
  exit 1
fi

if [ -z "$directory_name" ]; then
  echo "No directory name specified. Copying all matching directories."

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
else
  dest_dir="$dest_base_dir/$directory_name"
  source_dir="$source_base_dir/$directory_name"

  if [ ! -d "$dest_dir" ]; then
    echo "Error: Destination directory '$dest_dir' does not exist."
    exit 1
  fi

  sshpass -p "$ADMIN_PASSWORD" rsync -av --delete --exclude='*/' --include='*.jar' --include='list.txt' "$dist_server:$source_dir/" "$dest_dir/plugins/"

  if [ $? -eq 0 ]; then
    echo "Success: Jar files copied successfully."
  else
    echo "Error: An error occurred while copying jar files."
  fi
fi
