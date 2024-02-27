#!/bin/bash

BASE_DIR="/opt/kitsunebi/data"
ENV_FILE="/opt/kitsunebi/secrets/restic.env"
EXCLUDE_FILE="/opt/kitsunebi/configs/scripts/backup-excludes"

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
  if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$RESTIC_REPOSITORY" ] || [ -z "$RESTIC_PASSWORD" ]; then
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

Check_restic_initialized() {
  restic snapshots >/dev/null 2>&1

  if [ $? -eq 0 ]; then
    Logger "INFO" "Restic repository is initialized"
  else
    Logger "ERROR" "Restic repository is not initialized"
    return 1
  fi
}

Get_tag() {
  local dir="$1"
  local tag=$(basename "$dir")

  Logger "INFO" "Tag: $(basename "$dir")"
  echo "$tag"
}

Main() {
  local dir="$1"

  Logger "INFO" "=== Starting backup for all directories in: $dir ==="

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

  Logger "INFO" "=== Backup completed for all directories in: $dir ==="
}

Perform() {
  local dir="$1"
  local backup_file="$dir/.backup"

  Logger "INFO" "Starting backup for directory: $dir"

  Check_file_exists "$backup_file" || {
    Logger "INFO" "Skipping backup for directory: $dir"
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

  # restic リポジトリが初期化されているか確認
  Check_restic_initialized || {
    return 1
  }

  # ディレクトリ名から tag を生成
  local tag=$(Get_tag "$dir")

  # バックアップを実行
  if [ -f "$EXCLUDE_FILE" ]; then
    restic backup --tag "$tag" --exclude-file="$EXCLUDE_FILE" "$dir"

    # 終了コードを確認
    if [ $? -eq 0 ]; then
      Logger "INFO" "Backup completed for directory: $dir"
    else
      return 1
    fi

  else
    # ファイルが存在しない場合は、失敗として処理を中断
    Logger "ERROR" "Exclude file not found"
    return 1
  fi
}

Main "$BASE_DIR"
