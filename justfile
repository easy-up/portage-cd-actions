version := `cat WORKFLOW_ENGINE_VERSION`

generate_docker_action:
	workflow-engine config generate-action --image docker://ghcr.io/cms-enterprise/batcave/workflow-engine-action:{{version}} \
	  --input "docker_auth_json:DOCKER_AUTH_JSON::The Docker config with credentials that will be used for ~/.docker/config.json" > image-build-scan-publish/docker/action.yml

generate_podman_action:
  workflow-engine config generate-action --image docker://ghcr.io/cms-enterprise/batcave/workflow-engine-action:podman-{{version}} \
    --input "container_registry:CONTAINER_REGISTRY::The container registry to login to" \
    --input "registry_user:REGISTRY_USER::The username for the container registry" \
    --input "registry_token:REGISTRY_TOKEN::The token or password for the container registry" > image-build-scan-publish/podman/action.yml
