version := "v0.0.1-rc.3"

generate_docker_action:
  workflow-engine config generate-action --image docker://ghcr.io/cms-enterprise/batcave/workflow-engine-action:{{version}} \
    --input "docker_auth_json:DOCKER_AUTH_JSON::The Docker config with credentials that will be used for ~/.docker/config.json (takes precedence over explicit registry credentials)" \
    --input "container_registry:CONTAINER_REGISTRY::The container registry to login to (used if no DOCKER_AUTH_JSON is provided)" \
    --input "registry_user:REGISTRY_USER::The username for the container registry (used if no DOCKER_AUTH_JSON is provided)" \
    --input "registry_token:REGISTRY_TOKEN::The token or password for the container registry (used if no DOCKER_AUTH_JSON is provided)" > image-build-scan-publish/docker/action.yml

generate_podman_action:
  workflow-engine config generate-action --image docker://ghcr.io/cms-enterprise/batcave/workflow-engine-action:podman-{{version}} \
    --input "docker_auth_json:DOCKER_AUTH_JSON::The Docker config with credentials that will be used for ~/.docker/config.json (takes precedence over explicit registry credentials)" \
    --input "container_registry:CONTAINER_REGISTRY::The container registry to login to (used if no DOCKER_AUTH_JSON is provided)" \
    --input "registry_user:REGISTRY_USER::The username for the container registry (used if no DOCKER_AUTH_JSON is provided)" \
    --input "registry_token:REGISTRY_TOKEN::The token or password for the container registry (used if no DOCKER_AUTH_JSON is provided)" > image-build-scan-publish/podman/action.yml
