#!/bin/bash

BASE_DIR="/opt/kitsunebi/data"
ENV_FILE="/opt/kitsunebi/secrets/github.env"
GIT_USERNAME=$(hostname)
GIT_EMAIL="admin@mcplay.biz"

Logger() {
  local level="$1"
  local message="$2"
  local timestamp=$(date +'%Y-%m-%d %H:%M:%S')
  echo "[$timestamp] [$level] - $message"
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
  if [ -z "$GITHUB_PERSONAL_ACCESS_TOKEN" ]; then
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

Main() {
  local dir="$1"

  Logger "INFO" "=== Starting commit for all directories in: $dir ==="

  # ディレクトリが存在するか確認
  Check_directory_exists "$dir" || {
    exit 1
  }

  # 環境変数を読み込む
  Load_env || {
    exit 1
  }

  # 必要な環境変数が設定されているか確認
  Check_env || {
    exit 1
  }

  # ディレクトリ内の全てのディレクトリに対して処理を実行
  for dir in "$dir"/*; do
    # ディレクトリの場合のみ処理を実行
    if [ -d "$dir" ]; then
     Perform "$dir"
    fi
  done

  Logger "INFO" "=== Commit completed for all directories in: $dir ==="
}

Perform() {
  local dir="$1"
  local git_dir="$dir/.git"

  Logger "INFO" "Starting commit for directory: $dir"

  # git ディレクトリが存在するか確認
  Check_directory_exists "$git_dir" || {
    return 1
  }

  cd "$dir" || exit 1

  # リモートリポジトリの URL
  local remote_url=$(git remote get-url origin)
  local remote_url_with_token=$(echo "$remote_url" | sed -E "s|^(https?://)|\1$GITHUB_PERSONAL_ACCESS_TOKEN@|")

  # リモートリポジトリの URL を書き換え
  git remote set-url origin "$remote_url_with_token"

  # 変更をコミット & プッシュ
  git add .
  git \
    -c "user.name=$GIT_USERNAME" \
    -c "user.email=$GIT_EMAIL" \
    commit \
    -m "kitsunebi: $(date +'%Y-%m-%d %H:%M:%S')"
  git push

  # リモートリポジトリの URL を元に戻す
  git remote set-url origin "$remote_url"

  Logger "INFO" "Commit completed for directory: $dir"
}

Main "$BASE_DIR"
