#!/bin/bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

expected_fingerprint="FE:E0:9E:77:43:BF:D4:3E:D7:D4:D3:ED:50:6C:C7:9D:2D:90:70:FF:A9:29:91:16:87:D4:27:33:70:BE:A3:06"

actual_fingerprint="$(
  openssl x509 \
    -in /usr/local/share/ca-certificates/custom-root-ca.crt \
    -noout \
    -sha256 \
    -fingerprint \
    | cut -d'=' -f2
)"

check "Default cert installed" \
  test -f /usr/local/share/ca-certificates/custom-root-ca.crt

check "Default cert linked" \
  test -L /etc/ssl/certs/custom-root-ca.pem

check "Default cert bundle installed" \
  test -f /usr/local/share/ca-certificates/custom-root-ca.bundle.crt

check "Default cert bundle linked" \
  test -L /etc/ssl/certs/custom-root-ca.bundle.pem

check "Fingerprint matches expected value" \
  test "${actual_fingerprint}" = "${expected_fingerprint}"

reportResults