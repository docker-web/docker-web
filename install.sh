#!/bin/bash

# docker-web Installation Script
# Usage: curl https://raw.githubusercontent.com/docker-web/docker-web/master/install.sh | sudo bash

set -e

# ═══════════════════════════════════════════════════════════════════════════
# Configuration
# ═══════════════════════════════════════════════════════════════════════════

REPO_URL="https://github.com/docker-web/docker-web.git"
REPO_NAME="docker-web"
PATH_DOCKERWEB="/var/docker-web"
PATH_MEDIA="$PATH_DOCKERWEB/media"
PATH_BACKUP="$PATH_DOCKERWEB/backup"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ═══════════════════════════════════════════════════════════════════════════
# Helper Functions
# ═══════════════════════════════════════════════════════════════════════════

log_info() {
  echo -e "${BLUE}[*]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[✓]${NC} $1"
}

log_error() {
  echo -e "${RED}[✗]${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}[!]${NC} $1"
}

# Check if running as root
check_root() {
  if [[ $EUID -ne 0 ]]; then
    log_error "This script must be run with sudo"
    echo "Usage: sudo bash install.sh"
    exit 1
  fi
}

# Check if command exists and is executable
check_command() {
  local cmd="$1"
  local display_name="${2:-$cmd}"
  
  if ! command -v "$cmd" &> /dev/null; then
    log_error "$display_name is not installed"
    exit 1
  fi
  log_success "$display_name is installed"
}

# Check all prerequisites
check_prerequisites() {
  log_info "Checking prerequisites..."
  echo
  
  check_command "curl" "curl"
  check_command "git" "git"
  check_command "docker" "docker"
  check_command "docker" "docker-compose" # will work for both "docker compose" and "docker-compose"
  
  echo
}

# Clone or update the repository
clone_or_update_repo() {
  if [ -d "$PATH_DOCKERWEB" ]; then
    log_warning "$PATH_DOCKERWEB already exists"
    read -p "Do you want to update it? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      log_info "Updating docker-web..."
      cd "$PATH_DOCKERWEB"
      git fetch origin
      git reset --hard origin/master
      log_success "docker-web updated"
    else
      log_warning "Installation cancelled"
      exit 0
    fi
  else
    log_info "Cloning docker-web repository..."
    cd /var
    git clone --depth 1 "$REPO_URL"
    log_success "Repository cloned"
  fi
}

# Create necessary directories
create_directories() {
  log_info "Creating necessary directories..."
  mkdir -p "$PATH_MEDIA"
  mkdir -p "$PATH_BACKUP"
  mkdir -p "$PATH_DOCKERWEB/.git/hooks"
  log_success "Directories created"
}

# Fix ownership if installed via sudo
fix_ownership() {
  if [[ -n "$SUDO_USER" ]]; then
    log_info "Setting ownership to $SUDO_USER..."
    chown -R "$SUDO_USER:$SUDO_USER" "$PATH_DOCKERWEB"
    log_success "Ownership set"
  fi
}

# Initialize config.sh if it doesn't exist
initialize_config() {
  if [ ! -f "$PATH_DOCKERWEB/config.sh" ]; then
    log_info "Initializing config.sh..."
    cat > "$PATH_DOCKERWEB/config.sh" << 'EOF'
#!/bin/bash
# docker-web Configuration
# Auto-generated during installation
# Edit this file to customize docker-web

export MAIN_DOMAIN=""
export MEDIA_DIR="/var/docker-web/media"
EOF
    chmod 600 "$PATH_DOCKERWEB/config.sh"
    log_success "config.sh created (will be configured on first run)"
  else
    log_warning "config.sh already exists, skipping"
  fi
}

# Clean old test apps if any
clean_test_apps() {
  log_info "Cleaning up old test artifacts..."
  if [ -d "$PATH_DOCKERWEB/apps" ]; then
    find "$PATH_DOCKERWEB/apps" -maxdepth 1 -type d -name "test-app-*" -exec rm -rf {} + 2>/dev/null || true
  fi
  log_success "Cleanup complete"
}

# Install shell aliases and completion
install_shell_integration() {
  log_info "Installing shell integration..."
  
  # Detect shell config file
  local SHELL_CONFIG=""
  if [[ -f "$HOME/.bashrc" ]]; then
    SHELL_CONFIG="$HOME/.bashrc"
  elif [[ -f "$HOME/.bash_profile" ]]; then
    SHELL_CONFIG="$HOME/.bash_profile"
  elif [[ -f "$HOME/.zshrc" ]]; then
    SHELL_CONFIG="$HOME/.zshrc"
  else
    log_warning "No shell config file found, skipping shell integration"
    return
  fi
  
  # Add alias.sh if not already there
  if ! grep -q "docker-web/src/alias.sh" "$SHELL_CONFIG" 2>/dev/null; then
    echo "source $PATH_DOCKERWEB/src/alias.sh" >> "$SHELL_CONFIG"
    log_success "Added alias.sh to $SHELL_CONFIG"
  fi
  
  # Add completion.sh if not already there
  if ! grep -q "docker-web/src/completion.sh" "$SHELL_CONFIG" 2>/dev/null; then
    echo "source $PATH_DOCKERWEB/src/completion.sh" >> "$SHELL_CONFIG"
    log_success "Added completion.sh to $SHELL_CONFIG"
  fi
}

# Install optional pre-commit hook
install_pre_commit_hook() {
  if [ -f "$PATH_DOCKERWEB/.git-hook-pre-commit" ]; then
    cp "$PATH_DOCKERWEB/.git-hook-pre-commit" "$PATH_DOCKERWEB/.git/hooks/pre-commit"
    chmod +x "$PATH_DOCKERWEB/.git/hooks/pre-commit"
    log_success "Pre-commit hook installed (optional: prevents pushing broken code)"
  fi
}

# Display final instructions
show_final_instructions() {
  echo
  echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
  echo -e "${GREEN}✓ docker-web installation complete!${NC}"
  echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
  echo
  echo "Next steps:"
  echo
  echo "1. Reload your shell configuration:"
  echo -e "   ${BLUE}source ~/.bashrc${NC}   # or ~/.bash_profile / ~/.zshrc"
  echo
  echo "2. Configure docker-web (first run only):"
  echo -e "   ${BLUE}docker-web config${NC}"
  echo
  echo "3. View available commands:"
  echo -e "   ${BLUE}docker-web help${NC}"
  echo
  echo "4. Launch an app:"
  echo -e "   ${BLUE}docker-web up nextcloud${NC}"
  echo
  echo "5. Run E2E tests before committing changes:"
  echo -e "   ${BLUE}docker-web test${NC}"
  echo
  echo "Documentation:"
  echo -e "   ${BLUE}README.md${NC}       - Project overview"
  echo -e "   ${BLUE}SETUP.md${NC}        - Setup guide"
  echo -e "   ${BLUE}TESTING.md${NC}      - Testing guide"
  echo -e "   ${BLUE}DEVELOPMENT.md${NC}  - Developer guide"
  echo
}

# ═══════════════════════════════════════════════════════════════════════════
# Main Installation Flow
# ═══════════════════════════════════════════════════════════════════════════

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║              docker-web Installer                         ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo

check_root
check_prerequisites

log_info "Starting installation..."
echo

clone_or_update_repo
create_directories
fix_ownership
initialize_config
clean_test_apps
install_shell_integration
install_pre_commit_hook

echo
show_final_instructions
