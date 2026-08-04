.PHONY: all cython ext doc clean test docker-build-env release

all: cython ext

cython:
	cython --version
	cython --cplus --fast-fail --annotate plyvel/_plyvel.pyx

ext: cython
	python setup.py build_ext --inplace --force

doc:
	python setup.py build_sphinx
	@echo
	@echo Generated documentation: "file://"$$(readlink -f doc/build/html/index.html)
	@echo

clean:
	git clean -fxq

test: ext
	python -m pytest

docker-build-env:
	docker build -t plyvel-build .

release: docker-build-env
	CIBW_BUILD='cp312*-manylinux_x86_64' \
	CIBW_MANYLINUX_X86_64_IMAGE=plyvel-build \
	CIBW_BEFORE_BUILD=scripts/cibuildwheel-before-build.sh \
	CIBW_PLATFORM=linux \
	cibuildwheel --output-dir wheelhouse
