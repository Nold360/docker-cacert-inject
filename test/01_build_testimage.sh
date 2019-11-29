#!/bin/bash
set -e
set -x
cp certs/ca.crt ../certs/
docker build --build-arg BASE_IMAGE=debian -t debian:ca-patched ..
