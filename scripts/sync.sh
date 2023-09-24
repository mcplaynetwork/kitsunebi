#!/bin/bash

while getopts ":common" opt; do
  case $opt in
  common)
    copy_common=true
    ;;
  \?)
    echo "Error: Invalid option: -$OPTARG" >&2
    exit 1
    ;;
  esac
done

shift $((OPTIND - 1))

subdirectory="$1"

local_dir="$HOME/dist/$1"

remote_server="username@remote_server_address"
remote_dir="/remote_directory_path/$1"

if [ -z "$1" ] || [ ! -d "$local_dir" ]; then
  echo "Error: Please specify a valid subdirectory name."
  exit 1
fi

rsync -av --delete --exclude='*' --include='*.jar' "$local_dir/" "$remote_server:$remote_dir/"

if [ $? -eq 0 ]; then
  echo "Success: Jar files copied successfully."
else
  echo "Error: An error occurred while copying jar files."
fi
