#!/bin/bash

# Used to identify the uploader
aws_user=$(aws sts get-caller-identity | jq  '.Arn' | sed 's/"//g')
# used to identify the git revision that generated the ami; append "-dirty" if there are uncommitted changes
git_revision="$(git rev-parse HEAD)$(if [ "$(git status --porcelain)" ]; then echo "-dirty"; fi)"
# The branch id
git_branch="$(git branch | awk '{print $2}')"

packer build \
    --var "aws_user=${aws_user}" \
    --var "git_revision=${git_revision}" \
    --var "git_branch=${git_branch}" \
    "$(dirname -- "$0")"
