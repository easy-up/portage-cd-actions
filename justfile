# Override with: just version=new-portage-action-version
version := "latest"

generate_docker_action:
  portage config generate-action --image docker://ghcr.io/easy-up/portage-action:{{version}} \
    --input "docker_auth_json:DOCKER_AUTH_JSON::The Docker config with credentials that will be used for ~/.docker/config.json (takes precedence over explicit registry credentials)" \
    --input "container_registry:CONTAINER_REGISTRY::The container registry to login to (used if no DOCKER_AUTH_JSON is provided)" \
    --input "registry_user:REGISTRY_USER::The username for the container registry (used if no DOCKER_AUTH_JSON is provided)" \
    --input "registry_token:REGISTRY_TOKEN::The token or password for the container registry (used if no DOCKER_AUTH_JSON is provided)" > image-build-scan-publish/docker/action.yml

generate_podman_action:
  portage config generate-action --image docker://ghcr.io/easy-up/portage-action:podman-{{version}} \
    --input "docker_auth_json:DOCKER_AUTH_JSON::The Docker config with credentials that will be used for ~/.docker/config.json (takes precedence over explicit registry credentials)" \
    --input "container_registry:CONTAINER_REGISTRY::The container registry to login to (used if no DOCKER_AUTH_JSON is provided)" \
    --input "registry_user:REGISTRY_USER::The username for the container registry (used if no DOCKER_AUTH_JSON is provided)" \
    --input "registry_token:REGISTRY_TOKEN::The token or password for the container registry (used if no DOCKER_AUTH_JSON is provided)" > image-build-scan-publish/podman/action.yml
