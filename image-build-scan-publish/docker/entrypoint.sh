#! /bin/sh

# Exit on Non-zero for subsequent commands
set -e

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

if ([ "$PORTAGE_IMAGE_BUILD_ENABLED" = "0" ] || [ "$PORTAGE_IMAGE_BUILD_ENABLED" = "false" ]); then
  if ([ "$PORTAGE_IMAGE_SCAN_ENABLED" = "1" ] || [ "$PORTAGE_IMAGE_SCAN_ENABLED" = "true" ]); then
    shout log "Pull Image Scan target tag. Image Build not enabled, Image Scan enabled."
    docker pull "$PORTAGE_IMAGE_TAG"
  fi
fi

git config --global --add safe.directory $GITHUB_WORKSPACE

echo "Is deployment enabled? $PORTAGE_DEPLOY_ENABLED"
echo "========== PORTAGE CONFIG =========="
cat "${PORTAGE_CONFIG:-.portage.yml}" || echo "no config"
echo "======== END PORTAGE CONFIG ========"

portage run all --verbose --semgrep-experimental
