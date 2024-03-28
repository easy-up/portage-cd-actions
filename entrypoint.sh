#!/bin/sh -l

# Exit on Non-zero for subsequent commands
set -e

ls -lah
pwd

if [ -z "$DOCKER_AUTH_JSON" ]; then
  mkdir -p ~/.docker
  echo $DOCKER_AUTH_JSON | jq . > ~/.docker/config.json
fi

git config --global --add safe.directory $GITHUB_WORKSPACE

workflow-engine run all --verbose --semgrep-experimental
