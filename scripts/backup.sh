#!/bin/bash

# Function to log messages
log_message() {
  local log_level="$1"
  local message="$2"
  local timestamp=$(date +'%Y-%m-%d %H:%M:%S')
  echo "[$timestamp] [$log_level] - $message"
}

# Function to load environment variables from .env file
load_env() {
  local env_file="$1"
  if [ -f "$env_file" ]; then
    source "$env_file"
  else
    log_message "ERROR" "$env_file not found"
    return 1
  fi
}

# Function to perform backup for a directory
perform_backup() {
  local dir="$1"
  local env_file="$dir/.env"
  local exclude_file="$dir/.EXCLUDES"

  log_message "INFO" "Starting backup for directory: $dir"

  load_env "$env_file" || {
    log_message "WARNING" "Skipping backup for directory $dir due to missing or unreadable .env file"
    return
  }

  # Check if required environment variables are set
  if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$RESTIC_REPOSITORY" ] || [ -z "$RESTIC_PASSWORD" ]; then
    log_message "ERROR" "Required environment variables are not set in $env_file"
    return 1
  fi

  # Check if restic repository is initialized
  check_restic_initialized || return 1

  # Perform the backup with exclude-file if available
  if [ -f "$exclude_file" ]; then
    restic backup --exclude-file="$exclude_file" "$dir"
  else
    restic backup "$dir"
  fi

  # Check the exit code of restic
  backup_exit_code=$?
  if [ $backup_exit_code -eq 0 ]; then
    log_message "INFO" "Backup completed for directory: $dir"
  else
    log_message "ERROR" "Backup failed for directory: $dir"
  fi
}

# Function to check if restic repository is initialized
check_restic_initialized() {
  restic snapshots >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    log_message "INFO" "Restic repository is initialized"
  else
    log_message "ERROR" "Restic repository is not initialized"
    return 1
  fi
}

# Main function to backup directories
backup_directories() {
  local base_dir="$1"

  log_message "INFO" "=== Starting backup for all directories in: $base_dir ==="

  # Check if base directory exists
  if [ ! -d "$base_dir" ]; then
    log_message "ERROR" "Base directory $base_dir not found"
    exit 1
  fi

  # Loop through each subdirectory in the base directory
  for dir in "$base_dir"/*; do
    # Check if it's a directory
    if [ -d "$dir" ]; then
      perform_backup "$dir"
    fi
  done

  log_message "INFO" "=== Backup completed for all directories in: $base_dir ==="
}

# Specify the base directory containing subdirectories to be backed up
BASE_DIR="/opt/kitsunebi/data"

# Perform backup for directories
backup_directories "$BASE_DIR"
