# Volumes

For production deployments, mount these paths to persist data across container restarts:

## Mount Points

| Path | Purpose |
|------|---------|
| `/var/www/html/public/fileadmin` | Editor uploads (images, documents, media) |
| `/var/www/html/var` | Cache, logs, sessions |
| `/var/www/html/config` | Site configuration |

## Security Notes

- Mount `fileadmin` and `var` as named Docker volumes or bind mounts with appropriate permissions
- Avoid exposing volume mounts directly to the host filesystem in production
- The `var` directory contains logs and session data — restrict access accordingly
- Back up `fileadmin` and database regularly — these contain user-generated content
- The `config` directory holds site configuration that may include sensitive settings
