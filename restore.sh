#!/bin/bash
set -e

# Settings
BACKUP_REPO="https://x-access-token:${GITHUB_TOKEN}@github.com/jsgillhq/vaultwarden-backup.git"
BACKUP_DIR="/data"
LOG_FILE="/data/restore.log"
RESTORE_TMP="/tmp/vaultwarden-backup"
LATEST_FILE=""

# Only restore if db doesn't exist
if [ -f "$BACKUP_DIR/db.sqlite3" ]; then
  echo "✅ DB already exists. Skipping restore." | tee -a "$LOG_FILE"
  exit 0
fi

# Clone backup repo
echo "🌀 Cloning backup repo..." | tee -a "$LOG_FILE"
rm -rf "$RESTORE_TMP"
git clone --depth=1 "$BACKUP_REPO" "$RESTORE_TMP"

# Find the latest backup file
LATEST_FILE=$(find "$RESTORE_TMP" -type f -name "*.sqlite3" | sort | tail -n 1)

if [ -z "$LATEST_FILE" ]; then
  echo "❌ No backup found to restore!" | tee -a "$LOG_FILE"
  
  # Optional: send Slack notification on failure
  if [ -n "$SLACK_WEBHOOK" ]; then
    curl -X POST -H 'Content-type: application/json' \
      --data "{\"text\":\"🚨 Vaultwarden restore failed: no backup file found.\"}" \
      "$SLACK_WEBHOOK"
  fi

  exit 1
fi

# Copy backup file
cp "$LATEST_FILE" "$BACKUP_DIR/db.sqlite3"
echo "✅ Restored from $LATEST_FILE" | tee -a "$LOG_FILE"

# Log restore time
echo "🕒 Restored at: $(date)" >> "$LOG_FILE"
