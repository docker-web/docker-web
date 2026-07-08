# docker-web E2E Testing Guide

## Quick Start

Run the full E2E test suite:

```bash
docker-web test
```

This will:
1. ✓ Create a temporary test application
2. ✓ Test all core docker-web commands
3. ✓ Run lifecycle operations (up, stop, restart, pause, unpause, down)
4. ✓ Test system commands (version, port, ls, help)
5. ✓ Clean up the test app automatically

## What Gets Tested

### Configuration & System
- ✓ `docker-web version` - Version command
- ✓ `docker-web ls` - List apps
- ✓ `docker-web port` - Port allocation
- ✓ `docker-web help` - Help system
- ✓ Configuration validation

### Application Lifecycle
- ✓ `docker-web create` - Create test app with nginx:alpine
- ✓ `docker-web up` - Full lifecycle (build + start + post-install)
- ✓ `docker-web stop` - Stop running container
- ✓ `docker-web start` - Start stopped container
- ✓ `docker-web restart` - Restart running container
- ✓ `docker-web pause` - Pause container
- ✓ `docker-web unpause` - Resume paused container
- ✓ `docker-web build` - Pull latest image and build
- ✓ `docker-web down` - Stop and remove volumes
- ✓ `docker-web logs` - Stream app logs
- ✓ `docker-web rm` - Remove app and folder

### Verification
- ✓ Container state transitions
- ✓ App listing after create
- ✓ Port allocation
- ✓ Log availability
- ✓ Shell function availability

## Test Output

```
[*] ═══════════════════════════════════════════════════════════
[*] docker-web E2E Test Suite
[*] ═══════════════════════════════════════════════════════════

[*] Testing: Version command
[✓] Version command
[*] Testing: List command (before test)
[✓] List command (before test)
...

[*] ═══════════════════════════════════════════════════════════
[*] Test Results Summary
[*] ═══════════════════════════════════════════════════════════

✓ Version command
✓ List command (before test)
...

Total: 25 | Passed: 25 | Failed: 0
Duration: 45s
✓ All tests passed!
```

## Understanding Test Results

### ✓ (Green) = PASSED
The operation completed successfully.

### ✗ (Red) = FAILED  
The operation failed. Check:
1. Docker is running
2. Network connectivity (for docker pull)
3. Disk space
4. Port availability

### ! (Yellow) = WARNING
Operation may have failed or be in an unexpected state, but doesn't block the test suite.

## Common Issues

### "Docker pull nginx:alpine failed (network issue?)"
**Solution**: Check internet connectivity or configure docker to use a proxy.

### "Build test app failed"
**Solution**: This is expected if network is slow. Build is optional for the E2E suite.

### "Verify app paused" fails
**Solution**: Container pause may not work on all systems. This is a warning, not a failure.

## How It Works

1. **Setup**: Test app name is generated with timestamp to avoid conflicts
2. **Cleanup**: A trap ensures the test app is removed even if the script fails
3. **Tests**: 25 different operations are tested sequentially
4. **Verification**: After each major operation, the test verifies the state changed correctly
5. **Teardown**: Test app is automatically removed (docker container + folder)

## Pre-deployment Checklist

Before pushing changes to docker-web:

```bash
# Run tests
docker-web test

# Check for syntax errors
bash -n src/cli.sh src/core/*.sh src/apps/*.sh src/helpers/*.sh

# Verify git is clean
git status

# Run tests one more time
docker-web test
```

## Advanced: Running Specific Tests

To test only specific operations, source the test file and call individual tests:

```bash
source /var/docker-web/src/core/test.sh

# This runs the full suite - modify the TEST() function for custom testing
```

## Continuous Integration

To use in CI/CD pipeline:

```bash
#!/bin/bash
set -e

docker-web test

if [ $? -eq 0 ]; then
  echo "All tests passed, safe to deploy"
  exit 0
else
  echo "Tests failed, aborting deployment"
  exit 1
fi
```

## Troubleshooting the Test Suite

### Test hangs
**Solution**: Check if a previous test app is still running
```bash
docker ps -a | grep "test-app-"
docker-web rm test-app-<ID> -y
```

### Port conflicts
**Solution**: Check what ports are in use
```bash
docker-web port
ss -tuln | grep 77
```

### Docker daemon issues
**Solution**: Restart Docker and try again
```bash
sudo systemctl restart docker
docker-web test
```

## Test Performance

Average test duration: **45-60 seconds**

Broken down:
- Setup/Config: 2s
- Create: 5s
- Build: 10-15s (depends on network)
- Lifecycle tests: 20-25s
- Cleanup: 3-5s

## Notes

- Tests are **safe** - they use a temporary app that's always cleaned up
- Tests require **Docker running** and **internet connectivity** for image pulling
- Tests are **idempotent** - can run multiple times safely
- Test app name includes **timestamp** to prevent collision with real apps
- All test artifacts are **automatically removed** at the end

## More Information

See:
- [SETUP.md](SETUP.md) - User setup guide
- [README.md](README.md) - Project overview
- [src/core/test.sh](src/core/test.sh) - Test implementation
