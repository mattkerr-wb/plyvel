.PHONY: all setup cython ext doc clean test docker-build-env release

all: ext cython setup

setup:		
	bash -c scripts/install-snappy.sh
	bash -c scripts/install-leveldb.sh
	uv venv --python 3.12 --clear
	. .venv/bin/activate
	uv pip sync requirements-dev.txt

cython: setup
	. .venv/bin/activate
	cython --version
	cython --cplus --fast-fail --annotate plyvel/_plyvel.pyx

ext: cython
	. .venv/bin/activate
	python setup.py build_ext --inplace --force

doc:
	python setup.py build_sphinx
	@echo
	@echo Generated documentation: "file://"$$(readlink -f doc/build/html/index.html)
	@echo

clean:
	python setup.py clean
	$(RM) plyvel/_plyvel.cpp plyvel/_plyvel*.so
	$(RM) -r testdb/
	$(RM) -r doc/build/
	$(RM) -r plyvel_wb.egg-info/
	$(RM) -r build/
	$(RM) -r leveldb/
	$(RM) -r snappy/
	find . -name '*.py[co]' -delete
	find . -name __pycache__ -delete

test: ext
	python -m pytest

docker-build-env:
	docker build -t plyvel-build .

release-macos:
	. .venv/bin/activate
	MACOSX_DEPLOYMENT_TARGET=15.0 \
	CIBW_BUILD='cp312* cp314*' \
	CIBW_SKIP='cp314t*' \
	cibuildwheel --output-dir wheelhouse --platform macos

release: docker-build-env
	. .venv/bin/activate
	CIBW_BUILD='cp312*_15_* cp314*_15_*' \
	CIBW_SKIP='cp314t*' \
	CIBW_BEFORE_BUILD=scripts/cibuildwheel-before-build.sh \
	cibuildwheel --output-dir wheelhouse --platform linux
