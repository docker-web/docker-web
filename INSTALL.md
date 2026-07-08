# Installation Guide

## Quick Start (Recommended)

### One-Line Installation

```bash
curl https://raw.githubusercontent.com/docker-web/docker-web/master/install.sh | sudo bash
```

That's it! The script will:
- ✓ Check prerequisites (curl, git, docker)
- ✓ Clone the repository to `/var/docker-web`
- ✓ Create necessary directories
- ✓ Set up shell aliases and tab completion
- ✓ Create initial configuration

### What Happens During Installation

1. **Prerequisites Check**: Verifies curl, git, and docker are installed
2. **Repository Clone**: Downloads docker-web to `/var/docker-web`
3. **Directory Setup**: Creates `/var/docker-web/media` and `/var/docker-web/backup`
4. **Shell Integration**: Adds aliases and completion to your `.bashrc`, `.bash_profile`, or `.zshrc`
5. **Configuration**: Creates an empty `config.sh` for you to customize
6. **Optional**: Installs pre-commit hook for automatic testing

### First-Time Setup

After installation, reload your shell and run the configuration wizard:

```bash
# Reload shell configuration
source ~/.bashrc

# Run configuration wizard (interactive)
docker-web config

# View available commands
docker-web help
```

## Manual Installation

If you prefer manual control, follow these steps:

### 1. Install Prerequisites

```bash
# Ubuntu/Debian
sudo apt-get install curl git docker.io docker-compose

# Or if using Docker's official repository
sudo apt-get install curl git docker-ce docker-compose-plugin
```

### 2. Clone Repository

```bash
sudo git clone --depth 1 https://github.com/docker-web/docker-web.git /var/docker-web
sudo chown -R $USER:$USER /var/docker-web
```

### 3. Create Directories

```bash
mkdir -p /var/docker-web/media
mkdir -p /var/docker-web/backup
```

### 4. Add Shell Integration

Add to your `~/.bashrc` or `~/.bash_profile`:

```bash
source /var/docker-web/src/alias.sh
source /var/docker-web/src/completion.sh
```

Then reload:

```bash
source ~/.bashrc
```

### 5. Configure

```bash
docker-web config
```

## Upgrading

### If Already Installed

Just run the installer again:

```bash
curl https://raw.githubusercontent.com/docker-web/docker-web/master/install.sh | sudo bash
```

It will detect the existing installation and ask if you want to update.

## Troubleshooting

### "curl: command not found"

Install curl:
```bash
sudo apt-get install curl  # Ubuntu/Debian
brew install curl          # macOS
```

### "docker: command not found"

Install Docker:
```bash
# Ubuntu/Debian
sudo apt-get install docker.io docker-compose

# Or use Docker's official installation
https://docs.docker.com/engine/install/
```

### "Permission denied" when running docker-web

Add your user to the docker group:
```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Commands not working after installation

Reload your shell:
```bash
source ~/.bashrc    # or ~/.bash_profile / ~/.zshrc
```

### "docker-web: command not found"

Make sure the aliases are sourced in your shell config:
```bash
grep "alias.sh" ~/.bashrc
# Should output: source /var/docker-web/src/alias.sh
```

If not found, add it manually and reload.

## System Requirements

- **OS**: Linux (Ubuntu 18.04+, Debian 10+, CentOS 7+, or similar)
- **CPU**: 2+ cores recommended
- **RAM**: 4GB minimum, 8GB+ recommended
- **Disk**: 10GB+ for docker images and app data
- **Network**: Internet connection for pulling docker images

## What Gets Installed

```
/var/docker-web/
├── src/                    - Main scripts
│   ├── cli.sh             - Command dispatcher
│   ├── env.sh             - Environment setup
│   ├── alias.sh           - Shell aliases
│   ├── completion.sh      - Tab completion
│   ├── core/              - Core commands
│   ├── apps/              - App commands
│   └── helpers/           - Helper functions
├── apps/                  - App configurations
│   ├── proxy/            - Reverse proxy (nginx-proxy)
│   ├── launcher/         - App launcher
│   └── [other apps]
├── template/             - Templates for new apps
├── media/                - App data (music, videos, etc)
├── backup/               - App backups
├── config.sh             - Your configuration (gitignored)
├── docker-compose.yml    - Main compose file
├── Dockerfile            - Main image definition
├── install.sh            - This installer
└── README.md             - Documentation
```

## Directories

- **`/var/docker-web`** - Main installation directory
- **`/var/docker-web/media`** - Shared media folder for apps
- **`/var/docker-web/backup`** - Backups of apps
- **`~/.bashrc`** - Modified to add aliases and completion

## File Permissions

After installation:
- docker-web directory is owned by your user
- `config.sh` has `chmod 600` (readable/writable by owner only)
- Shell config files are readable/writable

## Post-Installation

### Next Steps

1. **Configure docker-web**:
   ```bash
   docker-web config
   ```

2. **Review settings**:
   ```bash
   cat /var/docker-web/config.sh
   ```

3. **Start using it**:
   ```bash
   docker-web help
   docker-web ls
   docker-web up nextcloud
   ```

4. **Before making changes** (developers):
   ```bash
   docker-web test
   ```

### Learning Resources

- [README.md](../README.md) - Project overview
- [SETUP.md](../SETUP.md) - User setup guide
- [TESTING.md](../TESTING.md) - Testing guide
- [DEVELOPMENT.md](../DEVELOPMENT.md) - Developer guide

## Uninstalling

To completely remove docker-web:

```bash
# Remove from shell config
sudo sed -i '/docker-web/d' ~/.bashrc

# Remove the directory
sudo rm -rf /var/docker-web

# Reload shell
source ~/.bashrc
```

**Note**: This will NOT delete your app data in `/var/docker-web/media` or backups. 
Manually remove those if you want to delete everything:

```bash
sudo rm -rf /var/docker-web/media /var/docker-web/backup
```

## Getting Help

- [GitHub Issues](https://github.com/docker-web/docker-web/issues)
- [Documentation](https://github.com/docker-web/docker-web)
- Run `docker-web help` for command overview
