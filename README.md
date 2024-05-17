# Advanced stash backup system

## Backup principles
Follows [GFS backup strategy](https://www.backblaze.com/blog/better-backup-practices-what-is-the-grandfather-father-son-approach/)

- Weekly full backup
- Daily incremental with [sqldiff](https://sqlite.org/sqldiff.html)

Configure upload and notify with the .example.sh files

# Restoration
```bash
cat backup.diff.sql | sqlite3 parent.db
```