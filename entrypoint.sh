#!/bin/sh -l

time=$(date)
echo "time=$time" >> $GITHUB_OUTPUT

ls -lah
pwd

git config --global --add safe.directory /github/workspace

workflow-engine run all --verbose --semgrep-experimental
