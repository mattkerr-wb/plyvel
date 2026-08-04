#!/bin/sh

set -eux

python --version
cython --version

git clean -xfd
make cython

python setup.py sdist --dist-dir /output
