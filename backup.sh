#!/bin/bash
set -e

# Timestamp and folder (date only)
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
DATE_FOLDER=$(date +"%Y-%m-%d")
BACKUP_FILE="db-${TIMESTAMP}.sqlite3"

# Path to store the backup (e.g. 2025-04-19/db-2025-04-19_14-30-00.sqlite3)
DEST_FOLDER="/tmp/vaultwarden-backup/${DATE_FOLDER}"
mkdir -p "$DEST_FOLDER"

# Create backup file
cp /data/db.sqlite3 "${DEST_FOLDER}/${BACKUP_FILE}"

# Clone backup repo
cd /tmp
git clone https://x-access-token:${GITHUB_TOKEN}@github.com/jsgillhq/vaultwarden-backup.git
cd vaultwarden-backup

# Copy the new backup folder into the repo
cp -r "/tmp/vaultwarden-backup/${DATE_FOLDER}" .

# Prune folders older than 7 days
find . -maxdepth 1 -type d -name "20*" -mtime +7 -exec git rm -rf {} \;

# Git add, commit, push
git add .
git config user.name "Vaultwarden Backup Bot"
git config user.email "bot@vaultwarden.local"
git commit -m "Backup on $TIMESTAMP"
git push origin main
