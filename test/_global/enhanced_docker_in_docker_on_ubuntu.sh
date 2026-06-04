#!/bin/bash
# Global scenario test: run against the 'enhanced_docker_in_docker_on_ubuntu' scenario.

set -e

source dev-container-features-test-lib

check "global: docker is on PATH" bash -lc "command -v docker"
check "global: dockerd is on PATH" bash -lc "command -v dockerd"
check "global: docker daemon is running" bash -lc "docker info"
check "global: docker buildx is installed" bash -lc "docker buildx version"
check "global: docker compose is installed" bash -lc "docker compose version"

reportResults
