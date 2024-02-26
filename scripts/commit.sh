#!/bin/bash

data_dir="/opt/kitsunebi/data"

for dir in $data_dir/*; do
  if [ -d "$dir/.git" ]; then
    echo "Processing Git repository in: $dir"
    cd "$dir" || exit 1

    git add .
    git commit -m "kitsunebi: `date +'%Y-%m-%d %H:%M:%S'`"

    echo "Completed processing repository in: $dir"
  fi
done
