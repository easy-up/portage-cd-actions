#! /bin/sh

# Exit on Non-zero for subsequent commands
set -e

# Debug current user and permissions before changes
shout log "Current user and permissions before changes:"
id
ls -ld "$GITHUB_WORKSPACE"

# Configure git to trust the workspace as the portage user
su portage -s /bin/sh -c "git config --global --add safe.directory '$GITHUB_WORKSPACE'"
su portage -s /bin/sh -c "git config --global --add safe.directory '*'"

# Create and set permissions for semgrep directory
mkdir -p /github/home/.semgrep
chown -R portage:portage /github/home/.semgrep
chmod -R 777 /github/home/.semgrep

if [ -f "$DOCKER_AUTH_JSON" ]; then
  shout log "DOCKER_AUTH_JSON set, creating ~/.docker/config.json"
  mkdir -p ~/.docker
  echo $DOCKER_AUTH_JSON | jq . > ~/.docker/config.json
elif [ "$CONTAINER_REGISTRY" != "" ] && [ "$REGISTRY_USER" != "" ] && [ "$REGISTRY_TOKEN" != "" ]; then
	shout log "Logging in to registry $CONTAINER_REGISTRY as $REGISTRY_USER"
	echo "$REGISTRY_TOKEN" | docker login "$CONTAINER_REGISTRY" -u "$REGISTRY_USER" --password-stdin
else
  shout log "Skip docker config.json creation, DOCKER_AUTH_JSON not set"
fi

# Ensure we're in the workspace directory
cd "$GITHUB_WORKSPACE"

# Debug current user and permissions
shout log "Current user and permissions:"
id
ls -ld "$GITHUB_WORKSPACE"

# Ensure workspace and artifacts directory have proper permissions
shout log "Setting workspace permissions"
mkdir -p "$GITHUB_WORKSPACE/artifacts"

# Ensure artifacts directory exists and has proper permissions
shout log "Setting artifacts directory permissions"
chown -R portage:portage "$GITHUB_WORKSPACE"
chmod -R 777 "$GITHUB_WORKSPACE"

# Debug final permissions
shout log "Final permissions:"
ls -ld "$GITHUB_WORKSPACE/artifacts"

# Execute portage with arguments passed to the container as the portage user
su portage -s /bin/sh -c "portage $*"
