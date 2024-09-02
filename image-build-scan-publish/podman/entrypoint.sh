#! /bin/sh

# Exit on Non-zero for subsequent commands
set -e

chgrp -R podman "$GITHUB_WORKSPACE"
chmod -R g+w "$GITHUB_WORKSPACE"

su podman -s /bin/sh -c "git config --global --add safe.directory $GITHUB_WORKSPACE"

# Configure rootless container storage.
sed -i -e "s|^#\\? *rootless_storage_path *=.*$|rootless_storage_path=\"$GITHUB_WORKSPACE/.containers/storage\"|" /etc/containers/storage.conf

if [ -f "$DOCKER_AUTH_JSON" ]; then
  shout log "DOCKER_AUTH_JSON set, creating ~/.docker/config.json"
  mkdir -p ~/.docker
  echo $DOCKER_AUTH_JSON | jq . > ~/.docker/config.json
elif [ "$CONTAINER_REGISTRY" != "" ] && [ "$REGISTRY_USER" != "" ] && [ "$REGISTRY_TOKEN" != "" ]; then
	shout log "Logging in to registry $CONTAINER_REGISTRY as $REGISTRY_USER"
	su podman -s /bin/sh -c "echo \"$REGISTRY_TOKEN\" | podman login --compat-auth-file \"\$HOME/.docker/config.json\" \"$CONTAINER_REGISTRY\" -u \"$REGISTRY_USER\" --password-stdin"
else
  shout log "Skipping docker config.json creation, neither DOCKER_AUTH_JSON or CONTAINER_REGISTRY/REGISTRY_USER/REGISTRY_TOKEN are set"
fi

if ([ "$PORTAGE_IMAGE_BUILD_ENABLED" = "0" ] || [ "$PORTAGE_IMAGE_BUILD_ENABLED" = "false" ]); then
  if ([ "$PORTAGE_IMAGE_SCAN_ENABLED" = "1" ] || [ "$PORTAGE_IMAGE_SCAN_ENABLED" = "true" ]); then
    shout log "Pull Image Scan target tag. Image Build not enabled, Image Scan enabled."
    su podman -s /bin/sh -c "docker pull \"$PORTAGE_IMAGE_TAG\""
  fi
fi

su podman -s /bin/sh -c "portage run all --verbose --semgrep-experimental --cli-interface podman"
