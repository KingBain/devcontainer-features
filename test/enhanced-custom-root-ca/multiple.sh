#!/bin/bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "Cert 1 installed" test -f /usr/local/share/ca-certificates/custom.sub.crt
check "Cert 2 installed" test -f /usr/local/share/ca-certificates/custom-1.sub.crt

check "Cert 1 linked" test -f /etc/ssl/certs/custom.sub.crt
check "Cert 2 linked" test -f /etc/ssl/certs/custom-1.sub.crt

reportResults
