#!/usr/bin/bash

source ../lib.sh

export CHECK_DISPLAYNAME="Host network"

run() {
  oc get crd nodenetworkconfigurationpolicies.nmstate.io \
  || fail_with Configuration "nmstate the tool for host network configuration does not seem to be installed. Did you install the nmstate operator?"
}

cleanup() {
  :
}

${@:-main}
