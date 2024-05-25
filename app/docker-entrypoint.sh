#!/usr/bin/env bash

# load schedules
export DIFF_CRON=${DIFF_CRON:-"0 0 * * *"}
echo "$DIFF_CRON cd /app && /app/backup-db.sh" >> /etc/crontabs/root

export FULL_CROM=${FULL_CROM:-"0 0 */7 * *"}
echo "$FULL_CROM cd /app && /app/backup-db.sh full" >> /etc/crontabs/root

export CONSOLIDATE_CRON=${CONSOLIDATE_CRON:-"0 0 2 * *"}
echo "$CONSOLIDATE_CRON cd /app && /app/consolidate-db.sh" >> /etc/crontabs/root

# run backup
/app/backup.sh && crond -f