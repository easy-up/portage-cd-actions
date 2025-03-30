#!/bin/sh

# Exit on Non-zero for subsequent commands
set -e

shout log "Starting entrypoint script"

# Debug initial state
shout log "Initial state:"
id
pwd
ls -la

# Setup git configuration in container
shout log "Setting up git configuration:"
git config --global --add safe.directory "$GITHUB_WORKSPACE"
git config --global --add safe.directory /github/workspace
git config --global init.defaultBranch main

# Ensure git knows about the branch
cd "$GITHUB_WORKSPACE"
git branch -M main
git branch --set-upstream-to=origin/main main

# Debug git state
shout log "Git state in container:"
echo "Current directory: $(pwd)"
echo "Branch info:"
git branch -vv
git rev-parse --abbrev-ref HEAD
git remote -v

# Ensure semgrep directory exists with proper permissions
mkdir -p /github/home/.semgrep
chown -R portage:portage /github/home/.semgrep
chmod -R 777 /github/home/.semgrep

# Set HOME for portage user
export HOME=/github/home

# Debug semgrep directory
shout log "Semgrep directory permissions:"
ls -la /github/home/.semgrep
ls -la /github/home

# Set up git configuration at system level
git config --system --add safe.directory '*'
git config --system --add safe.directory "$GITHUB_WORKSPACE"

# Create artifacts directory if it doesn't exist
mkdir -p "$GITHUB_WORKSPACE/artifacts"
chmod -R 777 "$GITHUB_WORKSPACE/artifacts"

# Reset any permission changes in git
cd "$GITHUB_WORKSPACE"
git reset --hard HEAD

# Handle Docker authentication
if [ -f "$DOCKER_AUTH_JSON" ]; then
    mkdir -p /home/portage/.docker
    echo "$DOCKER_AUTH_JSON" | jq . > /home/portage/.docker/config.json
    chown -R portage:portage /home/portage/.docker
elif [ "$CONTAINER_REGISTRY" != "" ] && [ "$REGISTRY_USER" != "" ] && [ "$REGISTRY_TOKEN" != "" ]; then
    echo "$REGISTRY_TOKEN" | docker login "$CONTAINER_REGISTRY" -u "$REGISTRY_USER" --password-stdin
fi

# Debug git configuration
shout log "Git configuration:"
git config --list --system
git config --list --global

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
    git config --global --add safe.directory '$GITHUB_WORKSPACE'
    portage $*
"
