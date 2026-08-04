#! /bin/bash

pip install -U setuptools wheel
pip install -U cibuildwheel

C_INCLUDE_PATH="/usr/local/include:$C_INCLUDE_PATH"
CPLUS_INCLUDE_PATH="/usr/local/include:$CPLUS_INCLUDE_PATH"
LIBRARY_PATH="/usr/local/lib:$LIBRARY_PATH"

clang -v && bash scripts/install-snappy.sh && bash scripts/install-leveldb.sh

pip install -r requirements-dev.txt

python -m setup.py sdist

python -m cibuildwheel --output-dir wheelhouse
