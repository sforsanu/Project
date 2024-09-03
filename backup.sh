#nano backup.sh 

#!/bin/bash

# Load environment variables from .env file
export $(grep -v '^#' .env | xargs)

# Backup Script
BACKUP_FILE="backup_$(date +"%Y%m%d_%H%M%S").sql"

# Perform database backup
PGPASSWORD="$PG_PASSWORD" pg_dump -U "$PG_USER" -d "$PG_DATABASE" > "$BACKUP_FILE"

# Compress the backup into a tar.gz file
tar -czvf "$BACKUP_FILE.tar.gz" "$BACKUP_FILE"

# Upload backup to Amazon S3
aws s3 cp "$BACKUP_FILE.tar.gz" "s3://$S3_BUCKET/$S3_PATH/$BACKUP_FILE.tar.gz"

# Check if the upload to S3 was successful
if [ $? -eq 0 ]; then
    echo "Backup uploaded to S3 successfully. Removing local backup files."
    # Remove the original SQL backup file and compressed file
    rm "$BACKUP_FILE"
    rm "$BACKUP_FILE.tar.gz"
else
    echo "Failed to upload backup to S3. Keeping local backup files."
fi
