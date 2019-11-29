# Docker CA-Certificate Injector
#
# Please configure the base image:tag you want to patch
ARG BASE_IMAGE
ARG BASE_TAG=latest

# Remove /magiccerts and magic script when finished? (default: true | false)
ARG VANISH=true

FROM ${BASE_IMAGE}:${BASE_TAG}
ARG VANISH
ENV VANISH=${VANISH}

# Lets do stuff..
COPY ./domagic.sh /usr/sbin/domagic.sh
COPY ./certs /magiccerts
RUN /usr/sbin/domagic.sh
