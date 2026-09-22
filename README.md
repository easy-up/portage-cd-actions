# Portage CD - Security Pipeline Action

Portage CD is an opinionated security pipeline designed to continuously deliver secure images to a registry

---

- [Usage](#usage)
  - [Multi-image GitHub Actions](#multi-image-github-actions)
- [Portable Portage contract](#portable-portage-contract)
- [Versioning](#versioning)
- [Customizing](#customizing)
  - [inputs](#inputs)
  - [outputs](#outputs)
- [Troubleshooting](#troubleshooting)

## Usage

This is an example configuration to dynamically generate an image tag before running `portage`

```yaml
jobs:
  portage:
    runs-on: ubuntu-latest
    name: Portage Code Scan + Image Delivery + Deployment Validation
    # Set required permissions for the job
    permissions:
      contents: write  # Required for creating directories and files
      packages: write  # Required for publishing packages
      id-token: write # Required for authentication
      
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # This fetches all history
          fetch-tags: true  # This fetches all tags
          
      # Set up workspace and artifacts directory
      - name: Create artifacts directory
        run: |
          mkdir -p $GITHUB_WORKSPACE/artifacts
          sudo chown 1001:1001 $GITHUB_WORKSPACE/artifacts  # Match container's portage user
          chmod -R 777 $GITHUB_WORKSPACE/artifacts  # Ensure container user can write
          
      - id: vars
        run: |
          REPO=$(echo "${{ github.repository }}" | tr '[:upper:]' '[:lower:]')
          echo full_image_tag="ghcr.io/${REPO}:${GITHUB_SHA::7}" >> $GITHUB_OUTPUT
          echo full_bundle_tag="ghcr.io/${REPO}-bundle:${GITHUB_SHA::7}" >> $GITHUB_OUTPUT
          
      - name: Run Portage CD
        uses: easy-up/portage-cd-actions/image-build-scan-publish/docker@belay_main
        env:
          DEPLOY_WEBHOOK_AUTH_HEADER: ${{ secrets.DEPLOY_WEBHOOK_AUTH_HEADER }}
        with:
          build_dir: "."
          dockerfile: "Dockerfile"
          tag: ${{ steps.vars.outputs.full_image_tag }}
          bundle_publish_tag: ${{ steps.vars.outputs.full_bundle_tag }}
          config_file: ".portage.yml"
          gatecheck_config_filename: ".custom-gatecheck.yml"
```

### Multi-image GitHub Actions

This repository is a GitHub-specific wrapper around Portage. The action inputs map GitHub workflow values into Portage's portable environment-variable contract; the wrapper does not own logical-build identity or infer sibling images.

For a matrix build, define the complete comma-delimited image-name list once and pass the same value and group ID to every matrix job. The list must contain no spaces or quoting. Only `image_name`, `tag`, and other image-specific settings vary:

```yaml
jobs:
  images:
    strategy:
      fail-fast: false
      matrix:
        include:
          - name: registry.example.com/team/api
            dockerfile: services/api/Dockerfile
          - name: registry.example.com/team/web
            dockerfile: services/web/Dockerfile
          - name: registry.example.com/team/worker
            dockerfile: services/worker/Dockerfile
          - name: registry.example.com/team/migrations
            dockerfile: services/migrations/Dockerfile
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: easy-up/portage-cd-actions/image-build-scan-publish/docker@belay_main
        with:
          build_group_id: github:${{ github.repository_id }}:${{ github.run_id }}:${{ github.run_attempt }}
          build_image_names: registry.example.com/team/api,registry.example.com/team/web,registry.example.com/team/worker,registry.example.com/team/migrations
          image_name: ${{ matrix.name }}
          tag: ${{ matrix.name }}:${{ github.sha }}
          dockerfile: ${{ matrix.dockerfile }}
          bundle_publish_tag: ${{ matrix.name }}-bundle:${{ github.sha }}
```

`github.run_id` is shared by all jobs in the workflow run. `github.run_attempt` increments when the workflow is rerun, so rerunning all jobs creates a new logical attempt. Do not rerun failed jobs only when replacing a grouped build: successful sibling jobs would remain in the previous attempt and the replacement group would be incomplete.

Grouped mode requires all three inputs together: `build_group_id`, `image_name`, and `build_image_names`. Supply all three to every image job, or omit all three to preserve legacy ungrouped behavior. Partial grouping context must not be used.

## Portable Portage contract

GitLab CI/CD, Jenkins, CircleCI, and other orchestrators should invoke Portage directly rather than use this GitHub Action. Set the underlying environment variables in every parallel image job:

```shell
PORTAGE_BUILD_GROUP_ID=ci:project-42:build-781
PORTAGE_BUILD_IMAGE_NAMES=registry.example.com/team/api,registry.example.com/team/web,registry.example.com/team/worker,registry.example.com/team/migrations
PORTAGE_IMAGE_NAME=registry.example.com/team/api
```

The CI orchestrator creates one opaque group ID per logical build. Every job gets that same ID and complete comma-delimited list; each job gets its own image name. Portage Actions, Portage, and Gatecheck transport these values without inference, and Belay consumes them.

Portage splits `PORTAGE_BUILD_IMAGE_NAMES` literally on commas. It does not trim spaces or implement quoted-field syntax. Use `api,web,worker,migrations`; do not use `api, web, worker, migrations` or `"api,web,worker,migrations"`. Spaces and literal quote characters would become part of the parsed image names.

For GitLab, use `gitlab:${CI_PROJECT_ID}:${CI_PIPELINE_ID}`. All jobs in a pipeline, including `parallel` and matrix jobs, share `CI_PIPELINE_ID`. Portage's [configuration guide](https://github.com/easy-up/portage-cd/blob/belay_main/docs/configuration.md#gitlab-cicd-identity) includes a four-image `parallel:matrix` example. A retried job keeps the same pipeline identity, so with Belay's current duplicate-artifact semantics it must not be used as a new grouped replacement. Start a new full pipeline to publish all images under a new ID. See GitLab's [predefined variables](https://docs.gitlab.com/ci/variables/predefined_variables/) and [job retry documentation](https://docs.gitlab.com/ci/jobs/#retry-jobs).

For parent/child pipelines, construct the group ID in the root pipeline and pass it explicitly to child pipelines; do not substitute each child's pipeline ID. See GitLab's [downstream pipeline variable forwarding](https://docs.gitlab.com/ci/pipelines/downstream_pipelines/).

Other providers can use `provider:project:logical-run`, as long as the value is new for a new full grouped attempt and identical across all image jobs. Never generate timestamps independently per job or use a per-job execution ID.
## Versioning

Portage CD Action loosely conforms to Semantic Versioning guidelines and format.

Git Tags will use the format `vMAJOR.MINOR.PATCH` or `vMAJOR.MINOR.PATCH-rc.X`

MAJOR: A change has been made to any action input / output that is NOT backwards compatible with previous versions

MINOR: A major or minor change has been made to Portage CD itself that may add or deprecate an action
input / output

PATCH: A minor or patch change has been made to Portage CD or the entrypoint script that does not impact an action
input or output, but may introduce minor functionality changes for optimization or bug fixes

Release Candidate (rc): Indicates a pre-release version intended for "testing in the wild" with no stability guarantees

### Differences with Portage CD Versions

Because Portage CD Actions may undergo multiple revisions or version changes while the version of the Portage CD tool
remains the same, the version of the Portage CD Action is non necessarily related to the version of Portage CD.

### Stability Guarantees 

While maintaining stability in a security pipeline is important, it's also important that tools are updated to inherit
any relevant upgrades to the underlying tools.
Portage CD depends on external tools with their own release cycles and definitions for what is considered a
'breaking change'.
For Portage CD and the Portage CD Action, breaking changes will be determined by the Maintainers of the
respective projects.

The mechanism by which we will provide some degree of stability is by using branches that will be fixed to certain
tags.

**vMAJOR-stable**: Will automatically pull in PATCH and MINOR releases.

**vMAJOR-beta**: Does not _officially_ come with stability guarantees for pre-stable-released features

**vMAJOR-alpha**: Does not come with any stability guarantees

## Customizing

Functionality to the underlying execution of Portage CD can be modified using GitHub Action inputs.

### Inputs

| Name                      | Type   | Default Value | Description                                                                    |
|---------------------------| ------ |---------------|--------------------------------------------------------------------------------|
| config_file               | String |               | The path to a config file to use when executing portage                        |
| tag                       | String | my-app:latest | The full image tag for the target container image                              |
| image_build_enabled       | Bool   | 1             | Enable/Disable the image build pipeline                                        |
| build_dir                 | String | .             | The build directory to using during an image build                             |
| dockerfile                | String | Dockerfile    | The Dockerfile/Containerfile to use during an image build                      |
| platform                  | String |               | The target platform for build (e.g., [linux/amd64])                            |
| target                    | String |               | The target build stage to build                                                |
| build_args                | List   |               | Comma seperated list of build time variables                                   |
| build_group_id            | String |               | CI-generated identity shared by every image in one logical build               |
| image_name                | String |               | Stable image name for this build job                                           |
| build_image_names         | String |               | Comma-delimited image names without spaces or quoting, shared by every job     |
| image_scan_enabled        | Bool   | 1             | Enable/Disable the image scan pipeline                                         |
| code_scan_enabled         | Bool   | 1             | Enable/Disable the code scan pipeline                                          |
| semgrep_rules             | String | p/default     | Semgrep ruleset manual override                                                |
| semgrep_src_dir           | String | .             | The target directory for the semgrep scan                                      |
| coverage_file             | String |               | An externally generated code coverage file to validate                         |
| image_publish_enabled     | Bool   | 1             | Enable/Disable the image publish pipeline                                      |
| bundle_publish_tag        | String |               | The full image tag for the target gatecheck bundle image blob                  |
| deploy_enabled            | Bool   | 1             | Enable/Disable the deploy pipeline                                             |
| gatecheck_config_filename | String |               | The filename for the gatecheck config                                          |
| docker_auth_json          | string |               | The Docker config with credentials that will be used for ~/.docker/config.json |

### Outputs

TODO: Add Content

## Troubleshooting

TODO: Add Content
