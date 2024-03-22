# Workflow Engine - Security Pipeline Action

Workflow Engine is an opinionated security pipeline designed to continuously deliver secure images to a registry

___

* [Usage](#usage)
* [Customizing](#customizing)
  * [inputs](#inputs)
  * [outputs](#outputs)
* [Troubleshooting](#troubleshooting)

## Usage

TODO: Add Usage Instructions

## Customizing

TODO: Add description

### Inputs

| Name                      | Type   | Default Value                        | Description                                                                        |
| ------------------------- | ------ | ------------------------------------ | ---------------------------------------------------------------------------------- |
| tag                       | String | my-app:latest                        | The full image tag for the target container image                                  |
| artifact_dir              | String | artifacts                            | The target directory for all generated artifacts                                   |
| gatecheck_bundle_filename | String | gatecheck-bundle.tar.gz              | The filename for the gatecheck bundle, a validatable archive of security artifacts |
| image_build_enabled       | Bool   | 1                                    | Enable/Disable the image build pipeline                                            |
| build_dir                 | String | .                                    | The build directory to using during an image build                                 |
| dockerfile                | String | Dockerfile                           | The Dockerfile/Containerfile to use during an image build                          |
| platform                  | String |                                      | The target platform for build                                                      |
| target                    | String |                                      | The target build stage to build (e.g., [linux/amd64])                              |
| cache_to                  | String |                                      | Cache export destinations (e.g., "user/app:cache", "type=local,src=path/to/dir")   |
| cache_from                | String |                                      | External cache sources (e.g., "user/app:cache", "type=local,src=path/to/dir")      |
| squash_layers             | Bool   | 0                                    | squash image layers - Only Supported with Podman CLI                               |
| build_args                | List   |                                      | Comma seperated list of build time variables                                       |
| image_scan_enabled        | Bool   | 1                                    | Enable/Disable the image scan pipeline                                             |
| syft_filename             | String | syft-sbom-report.json                | The filename for the syft SBOM report - must contain 'syft'                        |
| grype_config_filename     | String |                                      | The config filename for the grype vulnerability report                             |
| grype_filename            | String | grype-vulnerability-report-full.json | The filename for the grype vulnerability report - must contain 'grype'             |
| clamav_filename           | String | clamav-virus-report.txt              | The filename for the clamscan virus report - must contain 'clamav'                 |
| code_scan_enabled         | Bool   | 1                                    | Enable/Disable the code scan pipeline                                              |
| gitleaks_filename         | String | gitleaks-secrets-report.json         | The filename for the gitleaks secret report - must contain 'gitleaks'              |
| gitleaks_src_dir          | String | .                                    | The target directory for the gitleaks scan                                         |
| semgrep_filename          | String | semgrep-sast-report.json             | The filename for the semgrep SAST report - must contain 'semgrep'                  |
| semgrep_rules             | String | p/default                            | Semgrep ruleset manual override                                                    |
| image_publish_enabled     | Bool   | 1                                    | Enable/Disable the image publish pipeline                                          |
| bundle_publish_enabled    | Bool   | 1                                    | Enable/Disable gatecheck artifact bundle publish task                              |
| bundle_publish_tag        | String | my-app/artifact-bundle:latest        | The full image tag for the target gatecheck bundle image blob                      |
| deploy_enabled            | Bool   | 1                                    | Enable/Disable the deploy pipeline                                                 |
| gatecheck_config_filename | String |                                      | The filename for the gatecheck config                                              |

### Outputs

TODO: Add Content

## Troubleshooting

TODO: Add Content
