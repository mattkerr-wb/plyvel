#!/bin/sh

set -eux

python --version
python -m pip install cython==3.2.9 setuptools==84
cython --version

make clean
make cython

python setup.py sdist --dist-dir /output
