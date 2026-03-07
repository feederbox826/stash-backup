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

## Restoration
```bash
cat backup.diff.sql | sqlite3 full.sqlite
```

## File size savings (2025)
- `DIFF` 1/10mins
- `FULL` 1/day
- Database: 14.1 -> 20.5MB
- rescrape of scenes, lots of edits and diffs: 29.0MB
- Average day: 18.8MB
- Average month: 575.5MB
- Year: 6.8G (70.1MB compressed)
  - 397 full backups
  - 12,690 diffs
