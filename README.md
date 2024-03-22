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

| Config Key                        | Environment Variable                 | Default Value                        | Description                                                                        |
| --------------------------------- | ------------------------------------ | ------------------------------------ | ---------------------------------------------------------------------------------- |
| codescan.enabled                  | WFE_CODE_SCAN_ENABLED                | 1                                    | Enable/Disable the code scan pipeline                                              |
| codescan.gitleaksfilename         | WFE_CODE_SCAN_GITLEAKS_FILENAME      | gitleaks-secrets-report.json         | The filename for the gitleaks secret report - must contain 'gitleaks'              |
| codescan.gitleakssrcdir           | WFE_CODE_SCAN_GITLEAKS_SRC_DIR       | .                                    | The target directory for the gitleaks scan                                         |
| codescan.semgrepfilename          | WFE_CODE_SCAN_SEMGREP_FILENAME       | semgrep-sast-report.json             | The filename for the semgrep SAST report - must contain 'semgrep'                  |
| codescan.semgreprules             | WFE_CODE_SCAN_SEMGREP_RULES          | p/default                            | Semgrep ruleset manual override                                                    |
| deploy.enabled                    | WFE_IMAGE_PUBLISH_ENABLED            | 1                                    | Enable/Disable the deploy pipeline                                                 |
| deploy.gatecheckconfigfilename    | WFE_DEPLOY_GATECHECK_CONFIG_FILENAME | -                                    | The filename for the gatecheck config                                              |
| gatecheckbundlefilename           | WFE_GATECHECK_BUNDLE_FILENAME        | gatecheck-bundle.tar.gz              | The filename for the gatecheck bundle, a validatable archive of security artifacts |
| imagebuild.args                   | WFE_IMAGE_BUILD_ARGS                 | -                                    | Comma seperated list of build time variables                                       |
| imagebuild.builddir               | WFE_IMAGE_BUILD_DIR                  | .                                    | The build directory to using during an image build                                 |
| imagebuild.cachefrom              | WFE_IMAGE_BUILD_CACHE_FROM           | -                                    | External cache sources (e.g., "user/app:cache", "type=local,src=path/to/dir")      |
| imagebuild.cacheto                | WFE_IMAGE_BUILD_CACHE_TO             | -                                    | Cache export destinations (e.g., "user/app:cache", "type=local,src=path/to/dir")   |
| imagebuild.dockerfile             | WFE_IMAGE_BUILD_DOCKERFILE           | Dockerfile                           | The Dockerfile/Containerfile to use during an image build                          |
| imagebuild.enabled                | WFE_IMAGE_BUILD_ENABLED              | 1                                    | Enable/Disable the image build pipeline                                            |
| imagebuild.platform               | WFE_IMAGE_BUILD_PLATFORM             | -                                    | The target platform for build                                                      |
| imagebuild.squashlayers           | WFE_IMAGE_BUILD_SQUASH_LAYERS        | 0                                    | squash image layers - Only Supported with Podman CLI                               |
| imagebuild.target                 | WFE_IMAGE_BUILD_TARGET               | -                                    | The target build stage to build (e.g., [linux/amd64])                              |
| imagepublish.bundlepublishenabled | WFE_IMAGE_BUNDLE_PUBLISH_ENABLED     | 1                                    | Enable/Disable gatecheck artifact bundle publish task                              |
| imagepublish.bundletag            | WFE_IMAGE_PUBLISH_BUNDLE_TAG         | my-app/artifact-bundle:latest        | The full image tag for the target gatecheck bundle image blob                      |
| imagepublish.enabled              | WFE_IMAGE_PUBLISH_ENABLED            | 1                                    | Enable/Disable the image publish pipeline                                          |
| imagescan.clamavfilename          | WFE_IMAGE_SCAN_CLAMAV_FILENAME       | clamav-virus-report.txt              | The filename for the clamscan virus report - must contain 'clamav'                 |
| imagescan.enabled                 | WFE_IMAGE_SCAN_ENABLED               | 1                                    | Enable/Disable the image scan pipeline                                             |
| imagescan.grypeconfigfilename     | WFE_IMAGE_SCAN_GRYPE_CONFIG_FILENAME | -                                    | The config filename for the grype vulnerability report                             |
| imagescan.grypefilename           | WFE_IMAGE_SCAN_GRYPE_FILENAME        | grype-vulnerability-report-full.json | The filename for the grype vulnerability report - must contain 'grype'             |
| imagescan.syftfilename            | WFE_IMAGE_SCAN_SYFT_FILENAME         | syft-sbom-report.json                | The filename for the syft SBOM report - must contain 'syft'                        |

### Outputs

TODO: Add Content

## Troubleshooting

TODO: Add Content
