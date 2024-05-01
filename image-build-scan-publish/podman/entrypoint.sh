#! /bin/sh

# Exit on Non-zero for subsequent commands
set -e

chgrp -R podman "$GITHUB_WORKSPACE"
chmod -R g+w "$GITHUB_WORKSPACE"

su podman -s /bin/sh -c "git config --global --add safe.directory $GITHUB_WORKSPACE"

# Configure rootless container storage.
sed -i -e "s|^#\\? *rootless_storage_path *=.*$|rootless_storage_path=\"$GITHUB_WORKSPACE/.containers/storage\"|" /etc/containers/storage.conf

if [ "$CONTAINER_REGISTRY" != "" ] && [ "$REGISTRY_USER" != "" ] && [ "$REGISTRY_TOKEN" != "" ]; then
	echo "Logging in to registry $CONTAINER_REGISTRY as $REGISTRY_USER"
	su podman -s /bin/sh -c "echo \"$REGISTRY_TOKEN\" | podman login \"$CONTAINER_REGISTRY\" -u \"$REGISTRY_USER\" --password-stdin"
fi

su podman -s /bin/sh -c "workflow-engine run all --verbose --semgrep-experimental --cli-interface podman"
