# Override with: just version=new-portage-action-version
version := "belay-main-latest"
portage_repo := env("PORTAGE_REPO", "../portage-cd")

build_portage:
  just --justfile "{{portage_repo}}/justfile" build

generate_docker_action: build_portage
  "{{portage_repo}}/bin/portage" config generate-action --image docker://ghcr.io/easy-up/portage-action:{{version}} \
    --input "build_group_id:PORTAGE_BUILD_GROUP_ID::The CI-generated identity shared by every image in one logical build" \
    --input "image_name:PORTAGE_IMAGE_NAME::The stable image name for this build job" \
    --input "build_image_names:PORTAGE_BUILD_IMAGE_NAMES::Comma-separated CSV of the complete image-name set for the logical build" \
    --input "image_build_cache_from:PORTAGE_IMAGE_BUILD_CACHE_FROM::A location to pull cached layers from" \
    --input "image_build_cache_to:PORTAGE_IMAGE_BUILD_CACHE_TO::A location to push cached layers to" \
    --input "docker_auth_json:DOCKER_AUTH_JSON::The Docker config with credentials that will be used for ~/.docker/config.json (takes precedence over explicit registry credentials)" \
    --input "container_registry:CONTAINER_REGISTRY::The container registry to login to (used if no DOCKER_AUTH_JSON is provided)" \
    --input "registry_user:REGISTRY_USER::The username for the container registry (used if no DOCKER_AUTH_JSON is provided)" \
    --input "registry_token:REGISTRY_TOKEN::The token or password for the container registry (used if no DOCKER_AUTH_JSON is provided)" > image-build-scan-publish/docker/action.yml

generate_podman_action: build_portage
  "{{portage_repo}}/bin/portage" config generate-action --image docker://ghcr.io/easy-up/portage-action:podman-{{version}} \
    --input "build_group_id:PORTAGE_BUILD_GROUP_ID::The CI-generated identity shared by every image in one logical build" \
    --input "image_name:PORTAGE_IMAGE_NAME::The stable image name for this build job" \
    --input "build_image_names:PORTAGE_BUILD_IMAGE_NAMES::Comma-separated CSV of the complete image-name set for the logical build" \
    --input "docker_auth_json:DOCKER_AUTH_JSON::The Docker config with credentials that will be used for ~/.docker/config.json (takes precedence over explicit registry credentials)" \
    --input "container_registry:CONTAINER_REGISTRY::The container registry to login to (used if no DOCKER_AUTH_JSON is provided)" \
    --input "registry_user:REGISTRY_USER::The username for the container registry (used if no DOCKER_AUTH_JSON is provided)" \
    --input "registry_token:REGISTRY_TOKEN::The token or password for the container registry (used if no DOCKER_AUTH_JSON is provided)" > image-build-scan-publish/podman/action.yml

validate_action_mappings:
  @if grep -nH '^    default:' image-build-scan-publish/docker/action.yml image-build-scan-publish/podman/action.yml; then echo 'generated action inputs must not define defaults' >&2; exit 1; fi
  grep -Fqx '    description: Comma-separated CSV of the complete image-name set for the logical build' image-build-scan-publish/docker/action.yml
  grep -Eq '^    PORTAGE_BUILD_IMAGE_NAMES: .+inputs\.build_image_names.+$' image-build-scan-publish/docker/action.yml
  grep -Fqx '  image: docker://ghcr.io/easy-up/portage-action:belay-main-latest' image-build-scan-publish/docker/action.yml
  grep -Fqx '    description: Comma-separated CSV of the complete image-name set for the logical build' image-build-scan-publish/podman/action.yml
  grep -Eq '^    PORTAGE_BUILD_IMAGE_NAMES: .+inputs\.build_image_names.+$' image-build-scan-publish/podman/action.yml
  grep -Fqx '  image: docker://ghcr.io/easy-up/portage-action:podman-belay-main-latest' image-build-scan-publish/podman/action.yml

verify_generated_actions: generate_docker_action generate_podman_action validate_action_mappings
  git diff --exit-code -- image-build-scan-publish/docker/action.yml image-build-scan-publish/podman/action.yml
