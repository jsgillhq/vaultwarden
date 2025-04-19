#!/bin/bash
set -e

# Timestamp and folder (date only)
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
DATE_FOLDER=$(date +"%Y-%m-%d")
BACKUP_FILE="db-${TIMESTAMP}.sqlite3"

# Path to store the backup
DEST_FOLDER="/tmp/vaultwarden-backup/${DATE_FOLDER}"
mkdir -p "$DEST_FOLDER"

# Check if the DB exists
if [ ! -f /data/db.sqlite3 ]; then
  echo "⚠️  No DB file found at /data/db.sqlite3. Skipping backup."
  exit 0
fi

# Copy the database to backup folder
cp /data/db.sqlite3 "${DEST_FOLDER}/${BACKUP_FILE}"

# Clone the backup repo
cd /tmp
git clone "https://x-access-token:${GITHUB_TOKEN}@github.com/jsgillhq/vaultwarden-backup.git"
cd vaultwarden-backup

# Copy new backup in
cp -r "${DEST_FOLDER}" .

# Prune backups older than 7 days
find . -maxdepth 1 -type d -name "20*" -mtime +7 -exec rm -rf {} \;

# Commit and push
git config user.name "Vaultwarden Backup Bot"
git config user.email "bot@vaultwarden.local"
git add .
git commit -m "Backup on ${TIMESTAMP}" || echo "Nothing to commit"
git push origin main
