#!/bin/sh

# Function to find the next available port
ALLOCATE_PORT() {
  TYPE="$1"
  HIGHEST_PORT=0
  
  # Set port range based on type
  if [ "$TYPE" = "store" ]; then
    MIN_PORT=7700
    MAX_RANGE=7799
  else
    MIN_PORT=7800
    MAX_RANGE=7999
  fi

  # Find all used ports in env.sh files
  for file in /var/docker-web/store/apps/*/env.sh; do
    if [ -f "$file" ]; then
      while IFS= read -r line; do
        # Extract port number from PORT=1234
        port=$(echo "$line" | grep -o 'PORT=["'"'"']\?[0-9]\+["'"'"']\?' | grep -o '[0-9]\+' || true)
        if [ -n "$port" ] && [ "$port" -ge "$MIN_PORT" ] && [ "$port" -le "$MAX_RANGE" ] && [ "$port" -gt "$HIGHEST_PORT" ]; then
          HIGHEST_PORT=$port
        fi
      done < "$file"
    fi
  done

  # Calculate next available port
  if [ "$HIGHEST_PORT" -eq 0 ]; then
    echo "$MIN_PORT"
  elif [ $((HIGHEST_PORT + 1)) -le "$MAX_RANGE" ]; then
    echo $((HIGHEST_PORT + 1))
  else
    echo "Error: No available port in range $MIN_PORT-$MAX_RANGE" >&2
    return 1
  fi
  
  return 0
}

# Allow direct script execution
if [ "$1" = "store" ] || [ "$1" = "other" ]; then
  ALLOCATE_PORT "$1"
  exit $?
fi
