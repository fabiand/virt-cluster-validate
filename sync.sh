set -xe
bash -n app/*
podman -r build -t quay.io/fdeutsch/virtualization-validation . \
&& podman -r push quay.io/fdeutsch/virtualization-validation \
&& oc apply -f pipeline-virtualization-validation.yaml \
&& oc create -f run.yaml
