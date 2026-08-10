FROM quay.io/pypa/manylinux_2_39

COPY scripts/ .

RUN ./install-snappy.sh
RUN ./install-leveldb.sh

ENV PATH="/opt/python/cp314-cp314/bin:/opt/python/cp312-cp312/bin:${PATH}"

RUN pip install -U pip setuptools cython pipx
