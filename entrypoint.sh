#!/bin/sh -l

# Exit on Non-zero for subsequent commands
set -e

ls -lah
pwd

if [ -z "$DOCKER_AUTH_JSON" ]; then
  echo "Skip docker config.json creation, DOCKER_AUTH_JSON not set"
else
  echo "DOCKER_AUTH_JSON set, creating ~/.docker/config.json"
  mkdir -p ~/.docker
  echo $DOCKER_AUTH_JSON | jq . > ~/.docker/config.json
fi

if [[ -z "$WFE_IMAGE_BUILD_ENABLED" && -n "$WFE_IMAGE_SCAN_ENABLED" ]]; then
  echo "Pull Image Scan target tag. Image Build not enabled, Image Scan enabled."
  docker pull "$WFE_IMAGE_TAG"
fi

git config --global --add safe.directory $GITHUB_WORKSPACE

workflow-engine run all --verbose --semgrep-experimental
