#!/bin/bash

SCRIPT_NAME=$(basename "$0")
BASE_DIR="/opt/kitsunebi/data"
BASE_SOURCE_DIR="/opt/kitsunebi/plugins/dist"
ENV_FILE="/opt/kitsunebi/secrets/sync.env"

# START: common functions
Logger() {
  local log_level="$1"
  local message="$2"
  local timestamp=$(date +'%Y-%m-%d %H:%M:%S')
  echo "[$timestamp] [$log_level] - $message"
}

Load_env() {
  if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
  else
    Logger "ERROR" "$ENV_FILE not found"
    return 1
  fi
}

Check_env() {
  if [ -z "$SSH_HOST" ] || [ -z "$SSH_USER" ] || [ -z "$SSH_PASSWORD" ]; then
    Logger "ERROR" "Required environment variables are not set"
    return 1
  fi
}

Check_directory_exists() {
  local dir="$1"
  if [ ! -d "$dir" ]; then
    Logger "ERROR" "Directory $dir not found"
    return 1
  fi
}

Check_file_exists() {
  local file="$1"
  if [ ! -f "$file" ]; then
    Logger "ERROR" "File $file not found"
    return 1
  fi
}
# END: common functions

Main() {
  local dir="$1"

  Logger "INFO" "=== Starting $SCRIPT_NAME ==="

  # ディレクトリが存在するか確認
  Check_directory_exists "$dir" || {
    exit 1
  }

  # ディレクトリ内の全てのディレクトリに対して処理を実行
  for dir in "$dir"/*; do
    # ディレクトリの場合のみ処理を実行
    if [ -d "$dir" ]; then
      Perform "$dir"

      # 終了コードを確認
      if [ $? -ne 0 ]; then
        Logger "ERROR" "Backup failed for directory: $dir"
      fi

    fi
  done

  Logger "INFO" "=== Finished $SCRIPT_NAME ==="
}

Perform() {
  local dir="$1"
  local dir_name=$(basename "$dir")
  local sync_flag_file="$dir/.sync"

  local source_dir="$BASE_SOURCE_DIR/$dir_name"
  local dest_dir="$dir/plugins"

  Logger "INFO" "Syncing jar files..."

  Check_file_exists "$sync_flag_file" || {
    Logger "INFO" "Skipping $dir_name"
    return 0
  }

  # 環境変数を読み込む
  Load_env || {
    return 1
  }

  # 必要な環境変数が設定されているか確認
  Check_env || {
    return 1
  }

  sshpass -p "$SSH_PASSWORD" rsync -av --delete --exclude='*/' --include='*.jar' --include='list.txt' "$SSH_USER@$SSH_HOST:$source_dir/" "$dest_dir"

  # 終了コードを確認
  if [ $? -eq 0 ]; then
    Logger "INFO" "Successfully synced jar files from $dir_name."
  else
    Logger "ERROR" "An error occurred while syncing jar files from $dir_name."
    return 1
  fi
}

Main "$BASE_DIR"
