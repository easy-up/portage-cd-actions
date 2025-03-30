#!/bin/sh

# Exit on Non-zero for subsequent commands
set -e

shout log "Starting entrypoint script"

# Debug initial state
shout log "Initial state:"
id
ls -la "$GITHUB_WORKSPACE"

# Set up git configuration at system level (affects all users)
git config --system --add safe.directory '*'
git config --system --add safe.directory "$GITHUB_WORKSPACE"

# Create necessary directories with proper permissions
mkdir -p "$GITHUB_WORKSPACE/artifacts"
mkdir -p /github/home/.semgrep

# Set permissions
chown -R portage:portage "$GITHUB_WORKSPACE"
chmod -R 755 "$GITHUB_WORKSPACE"
chmod -R 777 "$GITHUB_WORKSPACE/artifacts"
chown -R portage:portage /github/home/.semgrep
chmod -R 777 /github/home/.semgrep

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

# Switch to portage user and run command
cd "$GITHUB_WORKSPACE"
exec su -s /bin/sh portage -c "portage $*"
