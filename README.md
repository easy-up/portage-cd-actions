# Workflow Engine - Security Pipeline Action

Workflow Engine is an opinionated security pipeline designed to continuously deliver secure images to a registry

---

- [Usage](#usage)
- [Versioning](#versioning)
- [Customizing](#customizing)
  - [inputs](#inputs)
  - [outputs](#outputs)
- [Troubleshooting](#troubleshooting)

## Usage

This is an example configuration to dynamically generate an image tag before running workflow engine

```yaml
jobs:
  workflow_engine:
    runs-on: ubuntu-latest
    name: Workflow Engine Code Scan + Image Delivery + Deployment Validation
    steps:
      - uses: actions/checkout@v4
      - id: vars
        run: |
          echo full_image_tag="ttl.sh/$(cat /proc/sys/kernel/random/uuid):30m" >> $GITHUB_OUTPUT
          echo full_bundle_tag="ttl.sh/$(cat /proc/sys/kernel/random/uuid):30m" >> $GITHUB_OUTPUT
      - name: Run Workflow Engine
        uses: cms-enterprise/batcave-workflow-engine-action@v1-stable
        # uses: ./.github/actions/workflow-engine
        with:
          build_dir: "."
          dockerfile: "Dockerfile"
          tag: ${{ steps.vars.outputs.full_image_tag }}
          bundle_publish_tag: ${{ steps.vars.outputs.full_bundle_tag }}
```

## Versioning

Workflow Engine Action loosely conforms to Semantic Versioning guidelines and format.

Git Tags will use the format `vMAJOR.MINOR.PATCH` or `vMAJOR.MINOR.PATCH-rc.X`

MAJOR: A change has been made to any action input / output that is NOT backwards compatible with previous versions

MINOR: A major or minor change has been made to Workflow Engine itself that may add or deprecate an action
input / output

PATCH: A minor or patch change has been made to Workflow Engine or the entrypoint script that does not impact an action
input or output, but may introduce minor functionality changes for optimization or bug fixes

Release Candidate (rc): Indicates a pre-release version intended for "testing in the wild" with no stability guarantees

### Stability Guarantees 

While maintaining stability in a security pipeline is important, it's also important that tools are updated to inherit
any relevant upgrades to the underlying tools.
Workflow Engine depends on external tools with their own release cycles and definitions for what is considered a
'breaking change'.
For Workflow Engine and the Workflow Engine Action, breaking changes will be determined by the Maintainers of the
respective projects.

The mechanism by which we will provide some degree of stability is by using branches that will be fixed to certain
tags.

**vMAJOR-stable**: Will automatically pull in PATCH and MINOR releases.

**vMAJOR-alpha**: Does not _officially_ come with stability guarantees for pre-stable-released features

**vMAJOR-beta**: Does not come with any stability guarantees

## Customizing

Functionality to the underlying execution of Workflow Engine can be modified using GitHub Action inputs.

### Inputs

| Name                   | Type   | Default Value                 | Description                                                                    |
| ---------------------- | ------ | ----------------------------- | ------------------------------------------------------------------------------ |
| tag                    | String | my-app:latest                 | The full image tag for the target container image                              |
| image_build_enabled    | Bool   | 1                             | Enable/Disable the image build pipeline                                        |
| build_dir              | String | .                             | The build directory to using during an image build                             |
| dockerfile             | String | Dockerfile                    | The Dockerfile/Containerfile to use during an image build                      |
| platform               | String |                               | The target platform for build                                                  |
| target                 | String |                               | The target build stage to build (e.g., [linux/amd64])                          |
| build_args             | List   |                               | Comma seperated list of build time variables                                   |
| image_scan_enabled     | Bool   | 1                             | Enable/Disable the image scan pipeline                                         |
| code_scan_enabled      | Bool   | 1                             | Enable/Disable the code scan pipeline                                          |
| semgrep_rules          | String | p/default                     | Semgrep ruleset manual override                                                |
| image_publish_enabled  | Bool   | 1                             | Enable/Disable the image publish pipeline                                      |
| bundle_publish_enabled | Bool   | 1                             | Enable/Disable gatecheck artifact bundle publish task                          |
| bundle_publish_tag     | String | my-app/artifact-bundle:latest | The full image tag for the target gatecheck bundle image blob                  |
| deploy_enabled         | Bool   | 1                             | Enable/Disable the deploy pipeline                                             |
| docker_auth_json       | string |                               | The Docker config with credentials that will be used for ~/.docker/config.json |

### Outputs

TODO: Add Content

## Troubleshooting

TODO: Add Content
