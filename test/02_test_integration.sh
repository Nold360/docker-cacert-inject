#!/bin/bash
# Run CA-Cert integration test
set -u
#set -x
set -e

#./genca.sh

# will test :latest only
IMAGE=('alpine' 'debian' 'centos' 'opensuse/leap')
IMAGE=('debian')
for img in ${IMAGE[@]} ; do
	echo Building test image based on $img
	echo -----------------
	docker build -t ${img}:ca-patched --build-arg BASE_IMAGE=${img} ..
	docker build -t catest_web .
	docker build -t catest_client --build-arg BASE_IMAGE=${img} -f Dockerfile.${img} .
	WEB=$(docker run --rm -d -h catest_web catest_web)
	echo
	echo -----------------
	echo starting test:
	if docker run --rm -ti --link $WEB:test catest_client wget -O- test ; then
		docker kill $WEB >> /dev/null
		echo
		echo --------------------------------------------------------
		echo "Success! CA-Certificate has been successfully injected"
		echo
		exit 0
	fi
	docker kill $WEB &> /dev/null
done
exit 1
