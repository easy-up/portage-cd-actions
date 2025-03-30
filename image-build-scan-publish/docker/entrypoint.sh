#!/bin/sh

# Exit on Non-zero for subsequent commands
set -e

shout log "Starting entrypoint script"

# Debug initial state
shout log "Initial state:"
id
pwd
ls -la

# Set up git configuration at system level first
git config --system --add safe.directory '*'
git config --system --add safe.directory "$GITHUB_WORKSPACE"
git config --system --add safe.directory /github/workspace

# Create necessary directories
mkdir -p "$GITHUB_WORKSPACE/artifacts"
mkdir -p /github/home/.semgrep

# Set permissions
chmod -R 777 "$GITHUB_WORKSPACE/artifacts"
chmod -R 777 /github/home/.semgrep

# Initialize git for portage user
su portage -c "
    cd '$GITHUB_WORKSPACE'
    export HOME=/github/home
    
    # Configure git
    git config --global --add safe.directory '$GITHUB_WORKSPACE'
    git config --global --add safe.directory /github/workspace
    git config --global --add safe.directory '*'
    
    # Set git identity (required for some git operations)
    git config --global user.email 'portage@github.actions'
    git config --global user.name 'Portage CI'
    
    # Verify git setup
    git rev-parse --git-dir
    git status
"

# Debug semgrep directory
shout log "Semgrep directory permissions:"
ls -la /github/home/.semgrep
ls -la /github/home

# Debug final permissions
shout log "Final workspace state:"
ls -la "$GITHUB_WORKSPACE"
ls -la "$GITHUB_WORKSPACE/artifacts"

# After initial debug output
shout log "Git repository state:"
ls -la "$GITHUB_WORKSPACE/.git" || echo "No .git directory found"
git status || echo "Git status failed"
git log --oneline -n 1 || echo "Git log failed"

# Switch to portage user and run command
exec su -s /bin/sh portage -c "
    export HOME=/github/home
    cd '$GITHUB_WORKSPACE'
    portage $*
"
