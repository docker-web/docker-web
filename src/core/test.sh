#!/bin/bash

# docker-web Quick Test Suite
# Tests that basic commands work correctly

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASSED=0
FAILED=0

log_info() {
  echo -e "${BLUE}[*]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[✓]${NC} $1"
  ((PASSED++))
}

log_error() {
  echo -e "${RED}[✗]${NC} $1"
  ((FAILED++))
}

test_cmd() {
  local name="$1"
  local cmd="$2"
  log_info "Testing: $name"
  if eval "$cmd" > /dev/null 2>&1; then
    log_success "$name"
  else
    log_error "$name"
  fi
}

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║         docker-web Quick Test Suite                       ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo

log_info "Running basic validation tests..."
echo

# Test 1: Version script exists
test_cmd "Version script exists" "[[ -f /var/docker-web/src/core/version.sh ]]"

# Test 2: Help script exists
test_cmd "Help script exists" "[[ -f /var/docker-web/src/core/help.sh ]]"

# Test 3: Config file exists
test_cmd "Config file exists" "[[ -f /var/docker-web/config.sh ]]"

# Test 4: Config has required vars
test_cmd "Config has MAIN_DOMAIN" "grep -q 'MAIN_DOMAIN' /var/docker-web/config.sh"

# Test 5: Docker installed
test_cmd "Docker installed" "docker --version | grep -q Docker"

# Test 6: Docker compose available
test_cmd "Docker compose available" "docker compose version | grep -q 'Docker Compose'"

# Test 7: Core config script
test_cmd "Config command script" "[[ -f /var/docker-web/src/core/config.sh ]]"

# Test 8: App scripts exist
test_cmd "App up.sh exists" "[[ -f /var/docker-web/src/apps/up.sh ]]"
test_cmd "App reset.sh exists" "[[ -f /var/docker-web/src/apps/reset.sh ]]"
test_cmd "App start.sh exists" "[[ -f /var/docker-web/src/apps/start.sh ]]"
test_cmd "App logs.sh exists" "[[ -f /var/docker-web/src/apps/logs.sh ]]"

# Test 9: Helper scripts exist
test_cmd "Helper execute.sh" "[[ -f /var/docker-web/src/helpers/execute.sh ]]"
test_cmd "Helper allocate_port.sh" "[[ -f /var/docker-web/src/helpers/allocate_port.sh ]]"

# Test 10: Shell integration
test_cmd "Alias script exists" "[[ -f /var/docker-web/src/alias.sh ]]"
test_cmd "Completion script exists" "[[ -f /var/docker-web/src/completion.sh ]]"

# Test 11: .git directory exists
test_cmd "Git repository" "[[ -d /var/docker-web/.git ]]"

# Test 12: env.sh file
test_cmd "env.sh script" "[[ -f /var/docker-web/src/env.sh ]]"

# Test 13: cli.sh dispatcher
test_cmd "cli.sh dispatcher" "[[ -f /var/docker-web/src/cli.sh ]]"

echo
echo "═══════════════════════════════════════════════════════════"
echo -e "Results: ${GREEN}Passed: $PASSED${NC} | ${RED}Failed: $FAILED${NC}"
echo "═══════════════════════════════════════════════════════════"
echo

if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}✓ All tests passed!${NC}"
  echo "docker-web is ready to use"
  exit 0
else
  echo -e "${RED}✗ $FAILED test(s) failed${NC}"
  exit 1
fi
