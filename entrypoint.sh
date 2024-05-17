#!/usr/bin/env bash

# load CRON_SCHEDULE
CRON_SCHEDULE=${CRON_SCHEDULE:-"0 0 * * *"}
echo "$CRON_SCHEDULE cd /app && /app/backup.sh" > /etc/crontabs/root

# run backup
/app/backup.sh && crond -f