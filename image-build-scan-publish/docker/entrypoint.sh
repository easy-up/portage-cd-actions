#! /bin/sh

# Exit on Non-zero for subsequent commands
set -e

if [ -f "$DOCKER_AUTH_JSON" ]; then
  echo "[DEBUG] (portage-cd-action): DOCKER_AUTH_JSON set, creating ~/.docker/config.json"
  mkdir -p ~/.docker
  echo $DOCKER_AUTH_JSON | jq . > ~/.docker/config.json
elif [ "$CONTAINER_REGISTRY" != "" ] && [ "$REGISTRY_USER" != "" ] && [ "$REGISTRY_TOKEN" != "" ]; then
  echo "[DEBUG] (portage-cd-action): Logging in to registry $CONTAINER_REGISTRY as $REGISTRY_USER"
  echo "$REGISTRY_TOKEN" | docker login "$CONTAINER_REGISTRY" -u "$REGISTRY_USER" --password-stdin
else
  echo "[DEBUG] (portage-cd-action): Skip docker config.json creation, DOCKER_AUTH_JSON not set"
fi

if ([ "$PORTAGE_IMAGE_BUILD_ENABLED" = "0" ] || [ "$PORTAGE_IMAGE_BUILD_ENABLED" = "false" ]); then
  if ([ "$PORTAGE_IMAGE_SCAN_ENABLED" = "1" ] || [ "$PORTAGE_IMAGE_SCAN_ENABLED" = "true" ]); then
    echo "[DEBUG] (portage-cd-action): Image Build not enabled, Image Scan enabled. Pulling Image Scan target tag."
    docker pull "$PORTAGE_IMAGE_TAG"
  fi
fi

if ([ "$PORTAGE_IMAGE_SCAN_ENABLED" = "1" ] || [ "$PORTAGE_IMAGE_SCAN_ENABLED" = "true" ]); then
  echo "[DEBUG] (portage-cd-action): Image Scan enabled. Updating grype db."
  GRYPE_DB_CACHE_DIR="$GITHUB_WORKSPACE/.cache/grype-db" grype db update
fi

git config --global --add safe.directory $GITHUB_WORKSPACE

# In order for --cache-from and --cache-to to work with BuildKit, we need to use the docker-container driver.
BUILDER_NAME=portage-buildkit-container
BUILDER_INSTANCE="$(docker buildx ls --format json | jq -r '.Name' | grep $BUILDER_NAME || echo "")"
if [ -z "$BUILDER_INSTANCE" ]; then
  echo "[DEBUG] (portage-cd-action): Creating buildx builder instance $BUILDER_NAME"
  docker buildx create --name $BUILDER_NAME --driver docker-container --driver-opt default-load=true --use --bootstrap
else
  echo "[DEBUG] (portage-cd-action): Using existing buildx builder instance of $BUILDER_NAME"
  docker buildx use $BUILDER_NAME
fi

GRYPE_DB_CACHE_DIR="$GITHUB_WORKSPACE/.cache/grype-db" portage run all --verbose --semgrep-experimental --use-buildx
