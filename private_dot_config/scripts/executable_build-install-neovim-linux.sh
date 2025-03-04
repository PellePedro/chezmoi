#!/bin/bash

set -e

cat <<EOF > Dockerfile.nvim
FROM debian:bullseye as builder

ARG NVIM_RELEASE=release-0.9

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && apt-get install --no-install-recommends -y \
    apt-transport-https \
    autoconf \
    automake \
    clang \
    cmake \
    curl \
    doxygen \
    g++ \
    gettext \
    git \
    gperf \
    libluajit-5.1-dev \
    libmsgpack-dev \
    libtermkey-dev \
    libtool \
    libtool-bin \
    libunibilium-dev \
    libutf8proc-dev \
    libuv1-dev \
    libvterm-dev \
    luajit \
    luarocks \
    make \
    ninja-build \
    pkg-config \
    unzip \
    ca-certificates

RUN luarocks build mpack && \
    luarocks build lpeg      && \
    luarocks build inspect

# Build neovim from source
ENV CMAKE_EXTRA_FLAGS="-DENABLE_JEMALLOC=OFF" \
  CMAKE_BUILD_TYPE="RelWithDebInfo"

RUN git clone https://github.com/neovim/neovim.git --branch \$NVIM_RELEASE \
  && cd neovim \
  && make \
  && make install

FROM scratch as artifact
COPY --from=builder /usr/local/bin/ .local/bin
COPY --from=builder /usr/local/share/nvim/ .local/share/nvim/
EOF

sudo DOCKER_BUILDKIT=1 docker build --target=artifact --output type=local,dest=${HOME} -f Dockerfile.nvim  .
