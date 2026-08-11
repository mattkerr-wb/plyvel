.PHONY: all setup cython doc clean test docker-build-env release

all: cython setup

setup: clean
	clang -v
	bash -c scripts/install-snappy.sh
	bash -c scripts/install-leveldb.sh
	. .venv/bin/activate
	uv sync --active

cython: setup
	. .venv/bin/activate
	cython --version
	cython --cplus --fast-fail --annotate plyvel/_plyvel.pyx

clean:
	git clean -fxqd
	uv clean

test: ext
	uvx pytest

docker-build-env:
	docker build -t plyvel-build .

release-macos:
	. .venv/bin/activate
	MACOSX_DEPLOYMENT_TARGET=15.0 \
	CIBW_BUILD='cp311-* cp312-* cp314-*' \
 	uvx cibuildwheel --output-dir wheelhouse --platform macos --build-front-end "build[uv]"

release: docker-build-env
	. .venv/bin/activate
	CIBW_BUILD='cp311-* cp312-* cp314-*' \
	CIBW_BEFORE_BUILD=scripts/cibuildwheel-before-build.sh \
	uvx cibuildwheel --output-dir wheelhouse --platform linux --build-front-end "build[uv]"
