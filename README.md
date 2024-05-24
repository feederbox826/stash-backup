# Advanced stash backup system

## Backup

- Full backups
  - Once every 7 days (or `FULL_CRON`)
  - When over 200 changes are made
- Incremental backup
  - based on last full backup, does not depend on previous incremental
- Backup consolidation
  - On the second of the month (or `CONSOLIDATE_CRON`)
  - If backed up more than once daily, consolidates by day otherwise month by month

Configure upload and notify with `.env` and `notify.sh`

## File size savings
Database: 9.3MB
- rescrape of scenes, lots of edits and diffs: 29.0MB
- 1 Day: 2.7MB
- month: tbd...

## Restoration
```bash
cat backup.diff.sql | sqlite3 full.sqlite
```