#!/bin/sh

# Exit on Non-zero for subsequent commands
set -e

shout log "Starting entrypoint script"

# Debug initial state
shout log "Initial state:"
id
pwd
ls -la

# Set HOME for portage user
export HOME=/github/home

# Set up git configuration for portage user
git config --global --add safe.directory /github/workspace
git config --global --add safe.directory '*'
git config --global core.excludesfile /home/portage/.gitignore_global
git config --global user.email 'portage@github.actions'
git config --global user.name 'Portage CI'

# Test git access
cd /github/workspace
git rev-parse --git-dir
git status

# Create necessary directories
mkdir -p "$GITHUB_WORKSPACE/artifacts"
mkdir -p /github/home/.semgrep

# Set permissions
chmod -R 777 "$GITHUB_WORKSPACE/artifacts"
chmod -R 777 /github/home/.semgrep

# Run portage command as portage user
exec su -s /bin/sh portage -c "
    export HOME=/github/home
    cd /github/workspace
    portage \$*
"
