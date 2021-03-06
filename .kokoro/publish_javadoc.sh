#!/bin/bash
set -eo pipefail

if [[ -z "${CREDENTIALS}" ]]; then
  CREDENTIALS=${KOKORO_KEYSTORE_DIR}/73713_docuploader_service_account
fi

# Set the version of python to 3.6
pyenv global 3.6.1

# Get into the spring-cloud-gcp repo directory
dir=$(dirname "$0")
pushd $dir/../

# Compute the project version.
PROJECT_VERSION=$(./mvnw help:evaluate -Dexpression=project.version -q -DforceStdout)

# Install docuploader package
python3 -m pip install --user gcp-docuploader

# Build the javadocs
./mvnw clean javadoc:aggregate

# Move into generated docs directory
pushd target/site/apidocs/

python3 -m docuploader create-metadata \
    --name spring-cloud-gcp \
    --version ${PROJECT_VERSION} \
    --language java

python3 -m docuploader upload . \
    --credentials ${CREDENTIALS} \
    --staging-bucket docs-staging

popd
popd
