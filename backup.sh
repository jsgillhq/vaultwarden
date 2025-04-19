#!/bin/bash
set -e

echo "🔁 Starting Vaultwarden backup process..."

# Timestamp and folder (date only)
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
DATE_FOLDER=$(date +"%Y-%m-%d")
BACKUP_FILE="db-${TIMESTAMP}.sqlite3"

# Path to store the backup
DEST_FOLDER="/tmp/vaultwarden-backup/${DATE_FOLDER}"
echo "📂 Creating destination folder: $DEST_FOLDER"
mkdir -p "$DEST_FOLDER"

# Check if the DB exists
if [ ! -f /data/db.sqlite3 ]; then
  echo "⚠️  No DB file found at /data/db.sqlite3. Skipping backup."
  exit 0
fi

echo "✅ DB file found. Creating backup file: ${BACKUP_FILE}"
cp /data/db.sqlite3 "${DEST_FOLDER}/${BACKUP_FILE}"

# Clone the backup repo
cd /tmp
echo "🌀 Cloning backup repo: https://x-access-token:[REDACTED]@github.com/jsgillhq/vaultwarden-backup.git"
git clone "https://x-access-token:${GITHUB_TOKEN}@github.com/jsgillhq/vaultwarden-backup.git"
cd vaultwarden-backup

# Copy new backup in
echo "📁 Copying backup folder into repo"
cp -r "${DEST_FOLDER}" .

# Prune backups older than 7 days
echo "🧹 Cleaning up old backups older than 7 days"
find . -maxdepth 1 -type d -name "20*" -mtime +7 -exec rm -rf {} \;

# Commit and push
echo "📦 Committing and pushing backup to remote"
git config user.name "Vaultwarden Backup Bot"
git config user.email "bot@vaultwarden.local"
git add .
git commit -m "Backup on ${TIMESTAMP}" || echo "ℹ️ Nothing to commit"
git push origin main
echo "🚀 Backup pushed to GitHub successfully"
