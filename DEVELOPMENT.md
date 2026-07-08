# Docker-web Development Workflow

## Before Making Changes

1. **Understand the architecture**: Read [README.md](README.md) and [SETUP.md](SETUP.md)
2. **Review TESTING.md**: Know what will be tested
3. **Check current status**: `docker-web ls` - see what's running

## Making Changes

1. **Create a branch** for your work:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** to:
   - Shell scripts in `src/core/`, `src/apps/`, `src/helpers/`
   - App configurations in `apps/*/`
   - Configuration in `config.sh` (will be gitignored)

3. **Test syntax** of any shell scripts:
   ```bash
   bash -n src/core/test.sh
   bash -n src/helpers/allocate_port.sh
   # Test all modified scripts...
   ```

## Before Committing

### Run the E2E Test Suite

```bash
docker-web test
```

This will:
- ✓ Create a temporary test application
- ✓ Test all modifications against real docker operations
- ✓ Clean up automatically
- ✓ Report any failures

### Expected Output

```
[*] ═══════════════════════════════════════════════════════════
[*] docker-web E2E Test Suite
[*] ═══════════════════════════════════════════════════════════

[✓] Version command
[✓] List command (before test)
[✓] Config test
[✓] Create test app: test-app-1234567890
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

### Troubleshooting Test Failures

#### Port conflicts
```bash
# Check allocated ports
docker-web port

# Find which app uses a port
docker ps | grep :7704
```

#### Docker issues
```bash
# Restart docker daemon
sudo systemctl restart docker
docker-web test
```

#### Network issues
```bash
# Some tests pull docker images - check internet
ping 8.8.8.8

# Check DNS
dig docker.io
```

#### Previous test app still exists
```bash
# Clean up orphaned test apps
docker-web rm test-app-* -y
```

## Automatic Testing with Git Hooks (Optional)

To run tests automatically before commits:

```bash
# Copy the pre-commit hook
cp .git-hook-pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# Now `git commit` will automatically run `docker-web test`
```

To bypass the hook if needed:
```bash
git commit --no-verify
```

## Commit Message Guidelines

Write clear, descriptive commit messages:

```
# Good
git commit -m "Fix: Prevent word-splitting in rm.sh with proper quoting"
git commit -m "Feature: Add E2E test suite for pre-deployment validation"
git commit -m "Security: Remove credentials from docker-compose files"

# Not great
git commit -m "Fixed stuff"
git commit -m "Updated scripts"
```

## After Testing - Ready to Push

1. **Final check**:
   ```bash
   git status
   ```
   Ensure no temporary test apps are staged.

2. **Check for secrets**:
   ```bash
   git diff --cached | grep -i password
   git diff --cached | grep -i secret
   git diff --cached | grep -i token
   # Should return nothing
   ```

3. **Review what you're pushing**:
   ```bash
   git diff origin/master src/
   ```

4. **Create a pull request** with description of changes

## Testing Different Components

### Test the CLI dispatcher
```bash
source src/cli.sh
[[ " ${COMMANDS[*]} " =~ " test " ]] && echo "test command available"
```

### Test a specific app
```bash
docker-web create my-test-app nginx:alpine
docker-web up my-test-app
docker-web logs my-test-app
docker-web rm my-test-app -y
```

### Test helpers
```bash
bash -n src/helpers/allocate_port.sh
bash -n src/helpers/generate_password.sh
bash -n src/helpers/setup_proxy.sh
```

### Test configuration
```bash
docker-web config  # Interactive config test
docker-web ls      # List apps
docker-web port    # Check port allocation
```

## Common Development Scenarios

### Debugging a failed test

1. Note which test failed from `docker-web test` output
2. Look at [TESTING.md](TESTING.md) to understand what it tests
3. Read [src/core/test.sh](src/core/test.sh) for the exact test code
4. Run that specific operation manually:
   ```bash
   docker-web up nextcloud
   docker-web logs nextcloud
   ```

### Adding a new command

1. Create `src/core/newcommand.sh` with function `NEWCOMMAND()`
2. The command is automatically available (via `ls` in env.sh)
3. Update help.sh to document it
4. Test: `docker-web test` will exercise all commands
5. Test manually: `docker-web newcommand`

### Modifying an existing command

1. Edit the file in `src/core/` or `src/apps/`
2. Run syntax check: `bash -n src/core/xxx.sh`
3. Run tests: `docker-web test`
4. Test manually with a real app
5. Commit and push

### Updating app configurations

1. Edit `apps/*/env.sh` or `apps/*/docker-compose.yml`
2. Test:
   ```bash
   docker-web down nextcloud
   docker-web up nextcloud
   ```
3. Verify app works via web UI
4. Run: `docker-web test`
5. Commit

## When Tests Fail

### Check the test logs
The test.sh script output shows exactly which test failed.

### Clean up and retry
```bash
# Remove any orphaned test apps
docker-web ls | grep test-app

# If found, remove them
docker-web rm test-app-XXXXX -y

# Try again
docker-web test
```

### Run individual tests
```bash
# Source and run specific test functions
source src/core/test.sh
# (modify TEST() function for what you want to test)
```

## Documentation

- [README.md](README.md) - Project overview
- [SETUP.md](SETUP.md) - User setup guide
- [TESTING.md](TESTING.md) - Testing guide
- [DEVELOPMENT.md](DEVELOPMENT.md) - This file (developer guide)

## Key Files to Know

| File | Purpose |
|------|---------|
| `src/cli.sh` | Main dispatcher - routes commands to handlers |
| `src/env.sh` | Environment variables and command discovery |
| `src/core/*.sh` | Core commands (create, init, upgrade, test, etc) |
| `src/apps/*.sh` | App lifecycle commands (up, down, restart, etc) |
| `src/helpers/*.sh` | Helper functions used by other scripts |
| `apps/*/` | Per-app configurations (env, docker-compose, etc) |
| `template/` | Templates for new apps |
| `config.sh` | User configuration (gitignored) |

## Questions?

See the tests in `src/core/test.sh` for examples of how commands should work.
