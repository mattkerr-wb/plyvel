FROM quay.io/pypa/manylinux_2_39_x86_64

COPY scripts/ .

RUN ./install-snappy.sh
RUN ./install-leveldb.sh

ENV PATH="/opt/python/cp312-cp312/bin:${PATH}"

RUN pip install -U pip setuptools cython
RUN pip install -U cibuildwheel
