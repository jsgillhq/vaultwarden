#!/bin/bash
set -e

# Timestamp for new backup
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="/data/db-${TIMESTAMP}.sqlite3"

# Create new backup file
cp /data/db.sqlite3 "$BACKUP_FILE"

# Clone backup repo
cd /tmp
git clone https://x-access-token:${GITHUB_TOKEN}@github.com/jsgillhq/vaultwarden-backup.git
cd vaultwarden-backup

# Clean backups older than 7 days
find . -name "db-*.sqlite3" -type f -mtime +7 -exec git rm -f {} \;

# Copy latest backup in
cp "$BACKUP_FILE" .
git add .

# Commit and push
git config user.name "Vaultwarden Backup Bot"
git config user.email "bot@vaultwarden.local"
git commit -m "Backup on $TIMESTAMP"
git push origin main
