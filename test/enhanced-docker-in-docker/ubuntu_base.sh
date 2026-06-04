#!/bin/bash
# This test file is executed against the 'ubuntu_base' scenario defined
# in test/enhanced-docker-in-docker/scenarios.json.

set -e

# Import test lib
source dev-container-features-test-lib

# Verify the explicit Ubuntu scenario installs the tools and starts the nested daemon.
check "ubuntu_base: docker is on PATH" bash -lc "command -v docker"
check "ubuntu_base: dockerd is on PATH" bash -lc "command -v dockerd"
check "ubuntu_base: docker daemon is running" bash -lc "docker info"
check "ubuntu_base: docker buildx is installed" bash -lc "docker buildx version"
check "ubuntu_base: docker compose is installed" bash -lc "docker compose version"

reportResults
