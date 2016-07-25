# torvitas/rundeck

## Configuration

### Available Configuration Parameters

| Parameter | Description |
|-----------|-------------|
| `SERVER_URL` | URL of the server. |
| `DATABASE_HOSTNAME` | Hostname of the database. This default to 'db'. |
| `DATABASE_NAME` | Name of the database, it defaults to $DB_ENV_MYSQL_NAME |
| `DATABASE_USER` | Username for the database, it defaults to $DB_ENV_MYSQL_USER |
| `DATABASE_PASSWORD` | Password for the database, it defaults to $DB_ENV_MYSQL_PASSWORD |
| `DATABASE_URL` | Jdbc URL for the database, optional. |
| `RUNDECK_PASSWORD` | Password for rundeck user, optional. |
| `RUNDECK_STORAGE_PROVIDER` | Defaults to file. |
| `RUNDECK_PROJECT_STORAGE_TYPE` | Defaults to file. |
| `ADMIN_USER` | Defaults to admin. |
| `ADMIN_PASSWORD` | Password for the admin user. |
| `RUNDECK_SSH_USER` | Defaults to rundeck. |

The final configuration is being saved to /etc/rundeck/settings.txt
