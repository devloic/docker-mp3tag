#
# mp3tag Dockerfile
#
# https://github.com/devloic/docker-mp3tag
#

# Docker image version is provided via build arg.
ARG DOCKER_IMAGE_VERSION=

# Define software versions.
ARG MYAPP_NAME=Mp3tag
ARG MYAPP_VERSION=3.27a


# Build myapp.

FROM alpine:3.17 AS myapp
COPY src /build

#mp3tag
COPY mp3tag /mp3tag
RUN /build/build.sh 

# Pull base image.
FROM jlesage/baseimage-gui:alpine-3.17-v4.6.4

ARG MYAPP_VERSION
ARG MYAPP_NAME
ARG DOCKER_IMAGE_VERSION

# Define working directory.
WORKDIR /tmp

# Install dependencies.
RUN \
    add-pkg \
        wine

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://raw.githubusercontent.com/devloic/docker-mp3tag/refs/heads/main/logomp3tag.png && \
    install_app_icon.sh "$APP_ICON_URL"

# Add files.
COPY rootfs/ /
COPY --from=myapp /opt/myapp /opt/myapp
COPY --from=myapp /defaults /defaults

# Set internal environment variables.
RUN \
    set-cont-env APP_NAME "$MYAPP_NAME" && \
    set-cont-env APP_VERSION "$MYAPP_VERSION" && \
    set-cont-env DOCKER_IMAGE_VERSION "$DOCKER_IMAGE_VERSION" && \
    true

# Define mountable directories.
VOLUME ["/music"]

# Metadata.
LABEL \
      org.label-schema.name="${MYAPP_NAME:-unknown}" \
      org.label-schema.description="Docker container for ${MYAPP_NAME:-unknown}" \
      org.label-schema.version="${DOCKER_IMAGE_VERSION:-unknown}" \
      org.label-schema.vcs-url="https://github.com/devloic/docker-mp3tag" \
      org.label-schema.schema-version="1.0"
