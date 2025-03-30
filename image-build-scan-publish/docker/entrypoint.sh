#!/bin/sh

# Exit on Non-zero for subsequent commands
set -e

shout log "Starting entrypoint script as $(id)"

# Verify workspace directory exists and is writable
if [ ! -d "$GITHUB_WORKSPACE" ]; then
    shout log "Error: GITHUB_WORKSPACE directory does not exist"
    exit 1
fi

# Test write access
touch "$GITHUB_WORKSPACE/test_write" || {
    shout log "Error: Cannot write to GITHUB_WORKSPACE"
    exit 1
}
rm "$GITHUB_WORKSPACE/test_write"

# Ensure artifacts directory exists with correct permissions
mkdir -p "$GITHUB_WORKSPACE/artifacts"
chown -R portage:portage "$GITHUB_WORKSPACE/artifacts"
chmod -R 777 "$GITHUB_WORKSPACE/artifacts"

# Setup git configuration for portage user
su portage -c "git config --global --add safe.directory '$GITHUB_WORKSPACE'"
su portage -c "git config --global --add safe.directory '*'"

# Initialize git repo if needed (as portage user)
cd "$GITHUB_WORKSPACE"
if [ ! -d .git ]; then
    su portage -c "git init && \
       git config --global user.email 'portage@example.com' && \
       git config --global user.name 'Portage User' && \
       git add . && \
       git commit -m 'Initial commit for scanning'"
fi

# Handle Docker authentication
if [ -f "$DOCKER_AUTH_JSON" ]; then
    mkdir -p /home/portage/.docker
    echo "$DOCKER_AUTH_JSON" | jq . > /home/portage/.docker/config.json
    chown -R portage:portage /home/portage/.docker
elif [ "$CONTAINER_REGISTRY" != "" ] && [ "$REGISTRY_USER" != "" ] && [ "$REGISTRY_TOKEN" != "" ]; then
    echo "$REGISTRY_TOKEN" | su portage -c "docker login '$CONTAINER_REGISTRY' -u '$REGISTRY_USER' --password-stdin"
fi

# Debug information
shout log "Workspace contents:"
ls -la "$GITHUB_WORKSPACE"
shout log "Git configuration:"
su portage -c "git config --list"

# Execute portage as the portage user with all arguments
exec su portage -c "portage $*"
