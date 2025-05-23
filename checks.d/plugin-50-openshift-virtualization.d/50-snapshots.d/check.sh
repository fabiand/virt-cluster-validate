#!/usr/bin/bash

source ../lib.sh

export CHECK_DISPLAYNAME="Snapshots"

run() {
  virtctl create vm --volume-import=type:ds,src:openshift-virtualization-os-images/fedora | tee vm.yaml
  oc create -f vm.yaml

#  oc wait --for=condition=Ready=true -f vm.yaml \
#  || fail_with Scheduling "Unable to schedule VMs?"

  VMNAME=$(oc get -o jsonpath='{.metadata.name}' -f vm.yaml)

  virtctl stop $VMNAME

  tee snap.yaml <<EOF
apiVersion: snapshot.kubevirt.io/v1alpha1
kind: VirtualMachineSnapshot
metadata:
  name: snap-${VMNAME}
spec:
  source:
    apiGroup: kubevirt.io
    kind: VirtualMachine
    name: ${VMNAME}
EOF
  oc apply -f snap.yaml

  oc wait -f snap.yaml --for condition=Ready \
  || fail_with Create  "Failed to create snapshot with default storageclass"

  tee restore.yaml <<EOF
apiVersion: snapshot.kubevirt.io/v1alpha1
kind: VirtualMachineRestore
metadata:
  name: restore-${VMNAME}
spec:
  target:
    apiGroup: kubevirt.io
    kind: VirtualMachine
    name: ${VMNAME}
  virtualMachineSnapshotName: snap-${VMNAME}
EOF
  oc apply -f restore.yaml
  oc wait -f restore.yaml --for condition=Ready \
  || fail_with Restore  "Failed to restore snapshots"
}

cleanup() {
  oc delete -f vm.yaml
  oc delete -f snap.yaml
  oc delete -f restore.yaml
}

${@:-main}
