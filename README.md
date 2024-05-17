# Advanced stash backup system

## Backup

- Full backups
  - Once every 7 days
  - When over 200 changes are made
- Incremental backup
  - based on last full backup, does not depend on previous backup
- Backup archive
  - If backed up more than once daily, consolidates by day
  - Otherwise, consolidates previous months together

Configure upload and notify with the .example.sh files

## File size savings
Database: 9.3MB
- rescrape of scenes, lots of edits and diffs: 29.0MB
- consolidation: 2.7MB
- month: tbd...

## Restoration
```bash
cat backup.diff.sql | sqlite3 full.sqlite
```