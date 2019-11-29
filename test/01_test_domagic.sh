#!/bin/bash
set -e
set -u

# will test :latest only
IMAGE=('alpine' 'debian' 'centos' 'opensuse/leap')

for img in ${IMAGE[@]} ; do
    echo --------------------------------------------
	echo TEST: Building $img
    echo --------------------------------------------
	docker build --no-cache --build-arg BASE_IMAGE=$img -t ${img}:ca-patched ..
	sleep 1
	docker image list | grep ca-patched | grep $img
	echo Successfully patched $img
done
