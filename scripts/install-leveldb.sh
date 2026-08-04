#!/usr/bin/env bash

set -ex

LEVELDB_VERSION=1.23

SUDO=$(command -v sudo || true)

# Check env
if [[ "$(uname)" == "Darwin" ]]; then
    export CFLAGS="-arch arm64 ${CFLAGS:-}"
    export CXXFLAGS="-arch arm64 ${CXXFLAGS:-}"
    export LDFLAGS="-arch arm64 ${LDFLAGS:-}"
    export C_INCLUDE_PATH=~/opt/local/include # where find snappy header files
    export CPLUS_INCLUDE_PATH=~/opt/local/include # where find snappy header files
    export LIBRARY_PATH=~/opt/local/lib # where find snappy library
fi

# Prepare leveldb source code
mkdir -p ~/opt/leveldb
cd ~/opt/leveldb
curl -sL leveldb.tar.gz https://codeload.github.com/google/leveldb/tar.gz/${LEVELDB_VERSION} | tar xzf -
cd leveldb-*

# Compile leveldb

# `CMAKE_INSTALL_NAME_DIR` and `CMAKE_SKIP_INSTALL_RPATH` only have effect for MacOS
if [[ "$(uname)" == "Darwin" ]]; then
    INSTALL_NAME_DIR="/usr/local/lib"
    $SUDO mkdir -p /usr/local/lib
    $SUDO mkdir -p /usr/local/include
    $SUDO chown runner:admin /usr/local/lib
    $SUDO chown runner:admin /usr/local/include
fi

mkdir -p build && cd build

cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_SKIP_INSTALL_RPATH=OFF \
    -DCMAKE_INSTALL_NAME_DIR=$INSTALL_NAME_DIR \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DLEVELDB_BUILD_TESTS=OFF \
    -DLEVELDB_BUILD_BENCHMARKS=OFF \
    ..

cmake --build . --target install

if [[ "$(uname)" == "Linux" ]]; then
    which ldconfig && ldconfig || true
fi

# Check leveldb shared lib in macOS
if [[ "$(uname)" == "Darwin" ]]; then
    otool -L $INSTALL_NAME_DIR/libleveldb.dylib
    file $INSTALL_NAME_DIR/libleveldb.dylib
fi
