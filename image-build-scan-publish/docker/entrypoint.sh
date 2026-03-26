#! /bin/sh

# Exit on Non-zero for subsequent commands
set -e

echo "============ Docker Info ============"
docker info
echo "============ Docker Buildx List ============"
docker buildx ls
echo "============ Portage ============"

if [ -f "$DOCKER_AUTH_JSON" ]; then
  echo "DOCKER_AUTH_JSON set, creating ~/.docker/config.json"
  mkdir -p ~/.docker
  echo $DOCKER_AUTH_JSON | jq . > ~/.docker/config.json
elif [ "$CONTAINER_REGISTRY" != "" ] && [ "$REGISTRY_USER" != "" ] && [ "$REGISTRY_TOKEN" != "" ]; then
	echo "Logging in to registry $CONTAINER_REGISTRY as $REGISTRY_USER"
	echo "$REGISTRY_TOKEN" | docker login "$CONTAINER_REGISTRY" -u "$REGISTRY_USER" --password-stdin
else
  echo "Skip docker config.json creation, DOCKER_AUTH_JSON not set"
fi

if ([ "$PORTAGE_IMAGE_BUILD_ENABLED" = "0" ] || [ "$PORTAGE_IMAGE_BUILD_ENABLED" = "false" ]); then
  if ([ "$PORTAGE_IMAGE_SCAN_ENABLED" = "1" ] || [ "$PORTAGE_IMAGE_SCAN_ENABLED" = "true" ]); then
    echo "Image Build not enabled, Image Scan enabled. Pulling Image Scan target tag."
    docker pull "$PORTAGE_IMAGE_TAG"
  fi
fi

if ([ "$PORTAGE_IMAGE_SCAN_ENABLED" = "1" ] || [ "$PORTAGE_IMAGE_SCAN_ENABLED" = "true" ]); then
  echo "Image Scan enabled. Updating grype db."
  GRYPE_DB_CACHE_DIR="$GITHUB_WORKSPACE/.cache/grype-db" grype db update
fi

git config --global --add safe.directory $GITHUB_WORKSPACE

GRYPE_DB_CACHE_DIR="$GITHUB_WORKSPACE/.cache/grype-db" portage run all --verbose --semgrep-experimental
