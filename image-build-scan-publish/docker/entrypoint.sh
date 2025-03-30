#! /bin/sh

# Exit on Non-zero for subsequent commands
set -e

# Configure git to trust the workspace
git config --global --add safe.directory '*'
git config --global --add safe.directory "$GITHUB_WORKSPACE"

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

# Create and set permissions for semgrep directory
mkdir -p /github/home/.semgrep
chown -R portage:portage /github/home/.semgrep
chmod -R 777 /github/home/.semgrep

# Debug info
shout log "Git configuration:"
git config --list
shout log "Workspace permissions:"
ls -la $GITHUB_WORKSPACE

if ([ "$PORTAGE_IMAGE_BUILD_ENABLED" = "0" ] || [ "$PORTAGE_IMAGE_BUILD_ENABLED" = "false" ]); then
  if ([ "$PORTAGE_IMAGE_SCAN_ENABLED" = "1" ] || [ "$PORTAGE_IMAGE_SCAN_ENABLED" = "true" ]); then
    shout log "Pull Image Scan target tag. Image Build not enabled, Image Scan enabled."
    docker pull "$PORTAGE_IMAGE_TAG"
  fi
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
chown -R portage:portage "$GITHUB_WORKSPACE/artifacts"
chmod -R 777 "$GITHUB_WORKSPACE/artifacts"

# Debug final permissions
shout log "Final permissions:"
ls -ld "$GITHUB_WORKSPACE/artifacts"

# Execute portage with arguments passed to the container
portage "$@"
