#!/bin/bash

# E2E Testing suite for docker-web
# Tests all critical operations: create, up, stop, restart, logs, rm

TEST_APP_NAME="test-app-$(date +%s)"
TEST_RESULTS=()
TEST_PASSED=0
TEST_FAILED=0
TEST_START_TIME=$(date +%s)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log helper
log_info() {
  echo -e "${BLUE}[*]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[✓]${NC} $1"
  TEST_RESULTS+=("✓ $1")
  TEST_PASSED=$((TEST_PASSED + 1))
}

log_error() {
  echo -e "${RED}[✗]${NC} $1"
  TEST_RESULTS+=("✗ $1")
  TEST_FAILED=$((TEST_FAILED + 1))
}

log_warning() {
  echo -e "${YELLOW}[!]${NC} $1"
}

# Test runner
run_test() {
  local test_name="$1"
  local test_cmd="$2"
  
  log_info "Testing: $test_name"
  
  if eval "$test_cmd" > /dev/null 2>&1; then
    log_success "$test_name"
  else
    log_error "$test_name"
    return 1
  fi
}

# Cleanup on exit
cleanup() {
  log_info "Cleaning up test artifacts..."
  
  # Stop test app if running
  if docker ps -a | grep -q "$TEST_APP_NAME"; then
    docker-web rm "$TEST_APP_NAME" -y > /dev/null 2>&1
    log_success "Test app removed"
  fi
  
  # Remove test docker-compose file if exists
  [[ -d "$PATH_APPS/$TEST_APP_NAME" ]] && rm -rf "$PATH_APPS/$TEST_APP_NAME"
  
  log_info "Cleanup complete"
}

# Trap for cleanup on exit or interrupt
trap cleanup EXIT INT TERM

TEST() {
  log_info "═══════════════════════════════════════════════════════════"
  log_info "docker-web E2E Test Suite"
  log_info "═══════════════════════════════════════════════════════════"
  echo

  # Test 1: VERSION
  run_test "Version command" "docker-web version" || log_error "Version failed"

  # Test 2: LS (list apps)
  run_test "List command (before test)" "docker-web ls" || log_error "List failed"

  # Test 3: CONFIG validation
  run_test "Config test" "[[ -n \$MAIN_DOMAIN ]] && [[ -f $PATH_DOCKERWEB/config.sh ]]" || log_error "Config validation failed"

  # Test 4: CREATE test app
  log_info "Creating test application with nginx:alpine..."
  if docker pull nginx:alpine > /dev/null 2>&1; then
    if bash -c "source $PATH_DOCKERWEB/config.sh && source $PATH_DOCKERWEB/src/env.sh && source $PATH_DOCKERWEB/src/cli.sh && CREATE $TEST_APP_NAME nginx:alpine" > /dev/null 2>&1; then
      log_success "Create test app: $TEST_APP_NAME"
      sleep 3  # Give docker time to start
    else
      log_error "Create test app failed"
      return 1
    fi
  else
    log_error "Docker pull nginx:alpine failed (network issue?)"
    return 1
  fi

  # Test 5: List should show test app
  run_test "List shows test app" "docker-web ls | grep -q $TEST_APP_NAME" || log_error "List after create failed"

  # Test 6: Port allocation
  run_test "Port command" "docker-web port" || log_error "Port failed"

  # Test 7: GET_STATE
  run_test "Get state for test app" "[[ -n \$(docker ps -a --format '{{.Names}}' | grep $TEST_APP_NAME) ]]" || log_error "Get state failed"

  # Test 8: LOGS
  run_test "Logs command" "docker-web logs $TEST_APP_NAME" || log_error "Logs failed"

  # Test 9: STOP
  run_test "Stop test app" "docker-web stop $TEST_APP_NAME" || log_error "Stop failed"
  sleep 2

  # Test 10: Verify stopped
  run_test "Verify app stopped" "docker ps | grep -q $TEST_APP_NAME && return 1 || return 0" || log_error "Verify stopped failed"

  # Test 11: START (using UP as restart)
  run_test "Start test app" "docker-web start $TEST_APP_NAME" || log_error "Start failed"
  sleep 2

  # Test 12: Verify running
  run_test "Verify app running" "docker ps | grep -q $TEST_APP_NAME" || log_error "Verify running failed"

  # Test 13: RESTART
  run_test "Restart test app" "docker-web restart $TEST_APP_NAME" || log_error "Restart failed"
  sleep 2

  # Test 14: Verify still running after restart
  run_test "Verify running after restart" "docker ps | grep -q $TEST_APP_NAME" || log_error "Verify restart failed"

  # Test 15: PAUSE
  run_test "Pause test app" "docker-web pause $TEST_APP_NAME" || log_error "Pause failed"
  sleep 1

  # Test 16: Verify paused
  run_test "Verify app paused" "docker ps -a --format '{{.Names}} {{.State}}' | grep -q '$TEST_APP_NAME paused'" || log_warning "Verify paused (may be expected)"

  # Test 17: UNPAUSE
  run_test "Unpause test app" "docker-web unpause $TEST_APP_NAME" || log_error "Unpause failed"
  sleep 1

  # Test 18: Verify unpaused
  run_test "Verify app unpaused" "docker ps | grep -q $TEST_APP_NAME" || log_error "Verify unpaused failed"

  # Test 19: BUILD (pull latest image)
  run_test "Build test app" "docker-web build $TEST_APP_NAME" || log_warning "Build failed (may timeout on network)"

  # Test 20: DOWN (stop and remove volumes)
  run_test "Down test app" "docker-web down $TEST_APP_NAME" || log_error "Down failed"
  sleep 2

  # Test 21: Verify down
  run_test "Verify app down" "docker ps -a | grep -q $TEST_APP_NAME && return 1 || return 0" || log_warning "Verify down (container may still exist)"

  # Test 22: UP (full lifecycle)
  run_test "Full UP lifecycle" "docker-web up $TEST_APP_NAME" || log_error "UP failed"
  sleep 3

  # Test 23: Final verification
  run_test "Final app verification" "docker ps | grep -q $TEST_APP_NAME" || log_error "Final verification failed"

  # Test 24: HELP command
  run_test "Help command" "docker-web help" || log_error "Help failed"

  # Test 25: Shell functions exist
  run_test "Core functions available" "[[ \$(declare -f UP | wc -l) -gt 0 ]]" || log_error "UP function missing"

  echo
  log_info "═══════════════════════════════════════════════════════════"
  log_info "Test Results Summary"
  log_info "═══════════════════════════════════════════════════════════"
  
  for result in "${TEST_RESULTS[@]}"; do
    echo "$result"
  done
  
  echo
  TEST_END_TIME=$(date +%s)
  TEST_DURATION=$((TEST_END_TIME - TEST_START_TIME))
  
  echo -e "Total: $(( TEST_PASSED + TEST_FAILED )) | ${GREEN}Passed: $TEST_PASSED${NC} | ${RED}Failed: $TEST_FAILED${NC}"
  echo "Duration: ${TEST_DURATION}s"
  
  if [ $TEST_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    return 0
  else
    echo -e "${RED}✗ Some tests failed${NC}"
    return 1
  fi
}

# Run tests
TEST
