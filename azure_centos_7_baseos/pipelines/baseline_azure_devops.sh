#!/usr/bin/env bash

usage() { echo "Usage: $0 -p <PAT Token>" 1>&2; exit 1; }

# Setup to the script working directory
cd "$(dirname "$0")"

# Read PAT token
while getopts ":p:" opt; do
  case $opt in
    p) export ADO_PAT="$OPTARG"
    ;;
    *) usage
    ;;
  esac
done

if [ -z "${ADO_PAT}" ]; then
    usage
fi

# Initialize environment
export GIT_REPOSITORY="engineering-vm-images"
export GIT_BRANCH=$(git branch | grep \* | cut -d ' ' -f2)
export IMAGE_NAME=$(basename $(dirname "$PWD"))

# Setup required cli extensions
az extension add --name azure-devops
az extension update --name azure-devops

az devops configure --defaults organization=https://dev.azure.com/transport-logistics project='Maersk VM Image Factory'

echo $ADO_PAT | az devops login 

# Update pipeline files

sed -i -e "s/<IMAGE_NAME>/$IMAGE_NAME/g" build.yml
sed -i -e "s/<IMAGE_NAME>/$IMAGE_NAME/g" publish.yml

# Create pipelines

az pipelines create \
    --name ${IMAGE_NAME}-build \
    --folder-path "engineering-vm-images" \
    --description "Build pipeline for ${IMAGE_NAME}" \
    --repository $GIT_REPOSITORY \
    --branch $GIT_BRANCH \
    --repository-type tfsgit \
    --skip-first-run true \
    --yml-path $(basename $(dirname "$PWD"))/$(basename "$PWD")/build.yml

az pipelines create \
    --name ${IMAGE_NAME}-publish \
    --folder-path "engineering-vm-images" \
    --description "Publish pipeline for ${IMAGE_NAME}" \
    --repository $GIT_REPOSITORY \
    --branch $GIT_BRANCH \
    --repository-type tfsgit \
    --skip-first-run true \
    --yml-path $(basename $(dirname "$PWD"))/$(basename "$PWD")/publish.yml

export BUILD_PIPELINE=$(az pipelines list \
    --name ${IMAGE_NAME}-build \
    | jq -r '.[].id')

export REPOSITORY_ID=$(az repos list | jq -r --arg repository $GIT_REPOSITORY '.[]|select (.name == $repository)|.id')

# Create Merge policy
az repos policy build create \
    --blocking true \
    --branch master \
    --build-definition-id $BUILD_PIPELINE \
    --display-name "${IMAGE_NAME}-build" \
    --enabled true \
    --manual-queue-only false \
    --repository-id $REPOSITORY_ID \
    --valid-duration 720 \
    --queue-on-source-update-only true \
    --path-filter "/$(basename $(dirname "$PWD"))/*;/ansible_roles/*;!**/*.md"