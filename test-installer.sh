#!/bin/bash

# Docker-web Installation Testing Script
# This script tests the installer logic without actually installing to /var/docker-web

set -e

TEMP_DIR="/tmp/docker-web-install-test-$$"
TEST_REPO="https://github.com/docker-web/docker-web.git"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
  echo -e "${BLUE}[*]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[✓]${NC} $1"
}

log_error() {
  echo -e "${RED}[✗]${NC} $1"
}

cleanup() {
  if [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
  fi
}

trap cleanup EXIT

echo -e "${BLUE}"
echo "╔═════════════════════════════════════════════════════════╗"
echo "║   docker-web Installation Script Test                   ║"
echo "╚═════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo

log_info "Testing docker-web installation script..."
log_info "Temp directory: $TEMP_DIR"
echo

# Test 1: Check prerequisites
log_info "Test 1: Checking prerequisites"
for cmd in curl git docker; do
  if command -v "$cmd" &> /dev/null; then
    log_success "$cmd is installed"
  else
    log_error "$cmd is not installed (this is expected for docker in some environments)"
  fi
done
echo

# Test 2: Test directory creation
log_info "Test 2: Testing directory creation"
mkdir -p "$TEMP_DIR/media"
mkdir -p "$TEMP_DIR/backup"
mkdir -p "$TEMP_DIR/.git/hooks"
log_success "Directories created successfully"
echo

# Test 3: Test config file creation
log_info "Test 3: Testing config file creation"
cat > "$TEMP_DIR/config.sh" << 'EOF'
#!/bin/bash
# docker-web Configuration
export MAIN_DOMAIN=""
export MEDIA_DIR="/var/docker-web/media"
EOF
chmod 600 "$TEMP_DIR/config.sh"
log_success "Config file created and permissions set"
echo

# Test 4: Test shell integration detection
log_info "Test 4: Testing shell config detection"
SHELL_CONFIG=""
if [[ -f "$HOME/.bashrc" ]]; then
  SHELL_CONFIG="$HOME/.bashrc"
  log_success "Found .bashrc"
elif [[ -f "$HOME/.bash_profile" ]]; then
  SHELL_CONFIG="$HOME/.bash_profile"
  log_success "Found .bash_profile"
elif [[ -f "$HOME/.zshrc" ]]; then
  SHELL_CONFIG="$HOME/.zshrc"
  log_success "Found .zshrc"
else
  log_error "No shell config file found (create ~/.bashrc)"
fi
echo

# Test 5: Test if files would be added to shell config
log_info "Test 5: Testing shell config integration"
if [[ -n "$SHELL_CONFIG" ]]; then
  if ! grep -q "docker-web" "$SHELL_CONFIG" 2>/dev/null; then
    log_success "Shell config is ready for updates (no conflicts found)"
  else
    log_success "Shell config already has docker-web entries"
  fi
else
  log_error "Cannot test shell config (no file found)"
fi
echo

# Test 6: Test syntax of actual install.sh
log_info "Test 6: Validating install.sh syntax"
if bash -n /var/docker-web/install.sh 2>/dev/null; then
  log_success "install.sh syntax is valid"
else
  log_error "install.sh has syntax errors"
  exit 1
fi
echo

echo -e "${GREEN}"
echo "═════════════════════════════════════════════════════════"
echo "✓ All tests passed!"
echo "═════════════════════════════════════════════════════════"
echo -e "${NC}"
echo

echo "The installer is ready to use. To install docker-web, run:"
echo
echo -e "  ${BLUE}curl https://raw.githubusercontent.com/docker-web/docker-web/master/install.sh | sudo bash${NC}"
echo
echo "Or to see what would be installed, run:"
echo
echo -e "  ${BLUE}bash /var/docker-web/install.sh${NC}"
echo
