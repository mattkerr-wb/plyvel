FROM quay.io/pypa/manylinux_2_39

COPY scripts/ .

RUN ./install-snappy.sh
RUN ./install-leveldb.sh

ENV PATH="/opt/python/cp314-cp314/bin:/opt/python/cp312-cp312/bin:/opt/python/cp311-cp311/bin:${PATH}"

RUN curl -LsSf https://astral.sh/uv/0.11.8/install.sh | sh

RUN uv sync --active
