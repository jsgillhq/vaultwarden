#!/bin/bash
set -e

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="/data/db-${TIMESTAMP}.sqlite3"

cp /data/db.sqlite3 "$BACKUP_FILE"

git clone https://x-access-token:${GITHUB_TOKEN}@github.com/jsgillhq/vaultwarden-backup.git /tmp/backup-repo
cd /tmp/backup-repo

cp "$BACKUP_FILE" .

git config user.name "Vaultwarden Backup Bot"
git config user.email "bot@vaultwarden.local"
git add .
git commit -m "Backup on $TIMESTAMP"
git push origin main
