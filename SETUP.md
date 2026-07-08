# docker-web Setup Guide

## No Pre-configured Passwords

docker-web no longer manages passwords. Each application handles its own authentication independently.

## First-time Setup

### 1. Configure docker-web

```bash
docker-web init
```

This will ask you for:
- **Domain**: Your main domain (e.g., `example.local`)
- **Media path**: Path where media files will be stored (optional)

### 2. Launch your first app

```bash
docker-web up nextcloud
```

Each app will be available at:
- `http://<app>.<MAIN_DOMAIN>`
- or `http://localhost:<PORT>`

## Creating Admin Accounts

### Nextcloud
When you first visit `https://cloud.example.local`, you'll be asked to create an admin account:
- Username: Choose any username
- Password: Choose a strong password
- Email: Your email address
- Data directory: Default is fine

### Umami
Default credentials on first setup:
- Email: `admin@example.com`
- Password: `umami`
**⚠️ Change these immediately after login!**

### Transmission
No authentication by default. Set username/password via:
- Web UI: Settings → Remote → Authentication
- Or access via `http://transmission.example.local:9091`

### Code Server
On first access, set your password via environment:
- The app generates a token on first run
- Check logs: `docker-web logs code`
- Access at `http://code.example.local`

### Penpot
Create your account on first visit:
- Visit `https://penpot.example.local`
- Sign up with email and password
- Verify your email (or use `DISABLE_EMAIL_VERIFICATION` in env)

## Managing Apps

### List all apps
```bash
docker-web ls
```

### Start/stop apps
```bash
docker-web up <app>      # Start
docker-web stop <app>    # Stop
docker-web restart <app> # Restart
```

### View logs
```bash
docker-web logs <app>
```

### Remove an app
```bash
docker-web rm <app>
```

## Security Best Practices

1. **Change default passwords** on all apps immediately after setup
2. **Use strong passwords** (minimum 16 characters)
3. **Configure SSL/TLS** via LETSENCRYPT_HOST in app configs
4. **Restrict network access** using firewalls
5. **Backup regularly** - Database files are in app folders
6. **Keep apps updated** - Run `docker-web update <app>` regularly

## Accessing Apps

### From local network
- `http://<app>.<MAIN_DOMAIN>` (requires /etc/hosts entry or DNS)
- `http://localhost:<PORT>` (direct port access)

### From outside (if exposed)
- `https://<app>.<MAIN_DOMAIN>` (SSL required)
- Use reverse proxy (nginx-proxy is included)

## Configuration

Each app stores configuration in:
```
/var/docker-web/apps/<app-name>/env.sh
```

Edit these files to customize ports, database names, or other settings.

## Troubleshooting

### App won't start
1. Check logs: `docker-web logs <app>`
2. Verify ports aren't in use: `docker-web ports`
3. Check disk space: `df -h`

### Can't access app
1. Verify it's running: `docker-web ls`
2. Check firewall: `sudo ufw allow <port>`
3. Verify domain resolves: `ping <app>.<MAIN_DOMAIN>`

### Database issues
Most apps use PostgreSQL with auto-generated internal passwords. If you need to reset:
1. Delete the app volume: `docker volume rm dockerweb_<app>_db`
2. Re-run the app: `docker-web up <app>`

## Default Ports

Apps are assigned ports starting at 7700 and incrementing:
- Nextcloud: 7704
- Umami: 7709
- Transmission: 9091 (configurable)
- Code: 7701-7703 (depending on order)

Check current allocations:
```bash
docker-web port
```
