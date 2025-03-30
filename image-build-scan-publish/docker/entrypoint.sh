#!/bin/sh

# Exit on Non-zero for subsequent commands
set -e

shout log "Starting entrypoint script"

# Debug initial state
shout log "Initial state:"
id
pwd
ls -la

# Debug git state in container
shout log "Git state in container:"
echo "Current directory: $(pwd)"
echo "GITHUB_WORKSPACE: $GITHUB_WORKSPACE"
ls -la "$GITHUB_WORKSPACE/.git" || echo "No .git directory found"
git rev-parse --git-dir || echo "Not in a git repository"
git status || echo "Git status failed"

# Configure git for portage user
su portage -s /bin/sh << 'EOF'
git config --global --add safe.directory "$GITHUB_WORKSPACE"
git config --global --list

# Test git commands as portage user:
echo "Testing git commands as portage user:"
pwd
git status
git rev-parse --git-dir
EOF

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

# Create necessary directories with proper permissions
mkdir -p "$GITHUB_WORKSPACE/artifacts"

# Set permissions
chown -R portage:portage "$GITHUB_WORKSPACE"
chmod -R 755 "$GITHUB_WORKSPACE"
chmod -R 777 "$GITHUB_WORKSPACE/artifacts"

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
cd "$GITHUB_WORKSPACE"
exec su -s /bin/sh portage -c "HOME=/github/home portage $*"
