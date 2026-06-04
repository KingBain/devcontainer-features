#!/bin/bash
# This test file will be executed against an auto-generated devcontainer.json
# that includes the 'enhanced-docker-in-docker' Feature with no options.
#
# Example devcontainer.json:
# {
#   "image": "<base-image-from-matrix>",
#   "features": {
#     "enhanced-docker-in-docker": {}
#   },
#   "remoteUser": "root"
# }

set -e

# Import test library bundled with the devcontainer CLI
# Provides the 'check' and 'reportResults' commands.
source dev-container-features-test-lib

# Feature-specific tests
check "docker is on PATH" bash -lc "command -v docker"
check "dockerd is on PATH" bash -lc "command -v dockerd"
check "docker daemon is running" bash -lc "docker info"
check "docker buildx is installed" bash -lc "docker buildx version"
check "docker compose is installed" bash -lc "docker compose version"

# Report results (fails if any check above failed)
reportResults
