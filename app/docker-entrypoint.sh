#!/usr/bin/env bash

# load schedules
export DIFF_CRON=${DIFF_CRON:-"0 0 * * *"}
echo "$DIFF_CRON cd /app && /app/backup-db.sh" >> /etc/crontabs/root

export FULL_CROM=${FULL_CROM:-"0 0 */7 * *"}
echo "$FULL_CROM cd /app && /app/backup-db.sh full" >> /etc/crontabs/root

export CONSOLIDATE_CRON=${CONSOLIDATE_CRON:-"0 0 2 * *"}
echo "$CONSOLIDATE_CRON cd /app && /app/consolidate-db.sh" >> /etc/crontabs/root

export IMG_CRON=${IMG_CRON:-"0 0 1 * *"}
echo "$IMG_CRON cd /app && /app/img-backup.sh" >> /etc/crontabs/root

# run backup
/app/backup-db.sh && /app/img-backup.sh
crond -f &