#!/bin/bash
# This test file is executed against the 'ubuntu_base' scenario defined
# in test/enhanced-docker-in-docker/scenarios.json.

set -e

# Import test lib
source dev-container-features-test-lib

# Verify the default installation and Docker-in-Docker behavior on Ubuntu.
check "ubuntu_base: docker is on PATH" bash -lc "command -v docker"
check "ubuntu_base: dockerd is on PATH" bash -lc "command -v dockerd"
check "ubuntu_base: docker daemon is reachable" bash -lc "docker info"
check "ubuntu_base: docker buildx is installed" bash -lc "docker buildx version"
check "ubuntu_base: docker compose is installed" bash -lc "docker compose version"
check "ubuntu_base: nested container runs" bash -lc "docker run --rm hello-world"

reportResults
