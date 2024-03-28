FROM ghcr.io/cms-enterprise/batcave/workflow-engine:v0.0.1-rc.14

COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
