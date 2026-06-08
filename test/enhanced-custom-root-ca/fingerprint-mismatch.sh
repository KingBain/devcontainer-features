#!/bin/bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

# If the container actually finishes building, it means our security feature
check "Cert NOT installed" [ ! -f /usr/local/share/ca-certificates/custom-root-ca.crt ]

reportResults
