#!/bin/sh

# Function to check if a port is actually in use
PORT_IN_USE() {
  local port="$1"
  if command -v ss >/dev/null 2>&1; then
    ss -tuln 2>/dev/null | grep -q ":$port "
  else
    netstat -tuln 2>/dev/null | grep -q ":$port "
  fi
}

# Function to find the next available port
ALLOCATE_PORT() {
  TYPE="$1"
  HIGHEST_PORT=0
  
  MIN_PORT=7700
  MAX_RANGE=7999

  # Find all used ports in env.sh and .env files
  for file in /var/docker-web/apps/*/env.sh /var/docker-web/apps/*/.env; do
    if [ -f "$file" ]; then
      while IFS= read -r line; do
        # Extract port number from PORT=1234 or PORT_DB=1234 etc.
        port=$(echo "$line" | grep -o 'PORT[^=]*=["'"'"']\?[0-9]\+["'"'"']\?' | grep -o '[0-9]\+' || true)
        if [ -n "$port" ] && [ "$port" -ge "$MIN_PORT" ] && [ "$port" -le "$MAX_RANGE" ] && [ "$port" -gt "$HIGHEST_PORT" ]; then
          HIGHEST_PORT=$port
        fi
      done < "$file"
    fi
  done

  # Calculate next available port and verify it's free
  local next_port
  if [ "$HIGHEST_PORT" -eq 0 ]; then
    next_port=$MIN_PORT
  else
    next_port=$((HIGHEST_PORT + 1))
  fi
  
  # Ensure port is in range and actually free
  while [ $next_port -le $MAX_RANGE ]; do
    if ! PORT_IN_USE "$next_port"; then
      echo "$next_port"
      return 0
    fi
    next_port=$((next_port + 1))
  done
  
  echo "Error: No available port in range $MIN_PORT-$MAX_RANGE" >&2
  return 1
}

# Allow direct script execution
if [ "$1" = "store" ] || [ "$1" = "other" ]; then
  ALLOCATE_PORT "$1"
  exit $?
fi
