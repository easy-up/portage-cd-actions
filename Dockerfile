FROM ghcr.io/cms-enterprise/batcave/workflow-engine:bd8e0bdb

COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
