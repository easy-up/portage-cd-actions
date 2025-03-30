#!/bin/sh

# Exit on Non-zero for subsequent commands
set -e

shout log "Starting entrypoint script"

# Debug initial state
shout log "Initial state:"
id
pwd
ls -la

# Set HOME and create necessary directories
export HOME=/github/home
mkdir -p "$GITHUB_WORKSPACE/artifacts"
mkdir -p /github/home/.semgrep

# Set permissions for portage user
chown -R portage:portage /github/home/.semgrep
chmod -R 777 /github/home/.semgrep
chmod -R 777 "$GITHUB_WORKSPACE/artifacts"

# Force entire .git folder to match portage's UID/GID
chown -R portage:portage /github/workspace/.git
chmod -R 755 /github/workspace/.git

# If you need to trust /github/workspace + *:
su portage -c "
  git config --global --add safe.directory /github/workspace
  git config --global --add safe.directory '*'
  echo '=== DEBUG: Git config after adding safe.directory ==='
  git config --list --show-origin
"

echo "=== DEBUG: Container user info ==="
whoami
id
ls -lad /github/workspace
ls -la /github/workspace/.git

# Run portage command as portage user
exec su -s /bin/sh portage -c "
    export HOME=/github/home
    cd /github/workspace
    portage \$*
"

sudo chown -R 1001:1001 $GITHUB_WORKSPACE
sudo chmod -R 755 $GITHUB_WORKSPACE

# Force .git directory to match user 1001:1001
sudo chown -R 1001:1001 $GITHUB_WORKSPACE/.git
sudo chmod -R 755 $GITHUB_WORKSPACE/.git

# Optional: double-check .git/index
ls -la $GITHUB_WORKSPACE/.git
