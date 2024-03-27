#!/bin/sh -l

time=$(date)
echo "time=$time" >> $GITHUB_OUTPUT

ls -lah
pwd

if [ -z "$DOCKER_AUTH_JSON" ]; then
  mkdir -p ~/.docker
  echo $DOCKER_AUTH_JSON | jq . > ~/.docker/config.json
fi

git config --global --add safe.directory /github/workspace

workflow-engine run all --verbose --semgrep-experimental
