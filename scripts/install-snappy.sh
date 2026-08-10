#!/usr/bin/env bash
set -ex

SNAPPY_VERSION=1.2.2
SUDO=$(command -v sudo || true)
SCRIPT="$( cd "$( dirname $0 )" && pwd )"

echo "OS: $(uname)"

# Check env
if [[ "$(uname)" == "Darwin" ]]; then
    export CFLAGS="-arch arm64 ${CFLAGS:-}"
    export CXXFLAGS="-arch arm64 ${CXXFLAGS:-}"
    export LDFLAGS="-arch arm64 ${LDFLAGS:-}"
    export MACOSX_DEPLOYMENT_TARGET=15
fi

# Prepare snappy source code
mkdir -p snappy
cd snappy
curl -sL https://codeload.github.com/google/snappy/tar.gz/${SNAPPY_VERSION} | tar xzf -
cd snappy-*

# Compile snappy

# `CMAKE_INSTALL_NAME_DIR` and `CMAKE_SKIP_INSTALL_RPATH` only have effect for MacOS
# [CMAKE_SKIP_RPATH/CMAKE_SKIP_INSTALL_RPATH and INSTALL_NAME_DIR precedence on macOS](https://gitlab.kitware.com/cmake/cmake/-/issues/16589)
# Set `INSTALL_NAME_DIR` to set the install name of shared library to be an absolute path instead of `@rpath/{target_name}`, which will help delocate the `wheel` 
# Or use `install_name_tool -change <old-path> <new-path> <file>` after .dylib was created

if [[ "$(uname)" == "Darwin" ]]; then
    INSTALL_NAME_DIR="/usr/local/lib"
fi

mkdir -p build && cd build

cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_SKIP_INSTALL_RPATH=OFF \
    -DCMAKE_INSTALL_NAME_DIR=$INSTALL_NAME_DIR \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DSNAPPY_BUILD_BENCHMARKS=OFF \
    -DSNAPPY_BUILD_TESTS=OFF \
    ..

$SUDO cmake --build . --target install

if [[ "$(uname)" == "Linux" ]]; then
    which ldconfig && ldconfig || true
fi

# Check snappy shared lib in macOS
if [[ "$(uname)" == "Darwin" ]]; then
    otool -L $INSTALL_NAME_DIR/libsnappy.dylib
    file $INSTALL_NAME_DIR/libsnappy.dylib
fi
