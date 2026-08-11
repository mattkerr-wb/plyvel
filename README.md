plyvel-wb
======

Another fork that creates pre-compiled Python wheels for `plyvel`, using a GitHub Action, intended to be used by WB Games. Currently aligns with Python 3.12, with 3.14 in the future.

Creation of a release should be done through GitHub, including the new tag, of format 'v<version>'. Do not push tags directly from your local repository, otherwise it will miss upload of the source distribution.

Pre-requisites
------

macOS:\
[CPython 3.11](https://www.python.org/ftp/python/3.11.9/python-3.11.9-macos11.pkg)\
[CPython 3.12](https://www.python.org/ftp/python/3.12.10/python-3.12.10-macos11.pkg)\
[Cpython 3.14](https://www.python.org/ftp/python/3.14.7/python-3.14.7-macos11.pkg)

Setup
------
```bash
make setup
. .venv/bin/activate
```
Source code for LevelDB and Snappy is downloaded to the repository.

Build
------
The build relies on `pypa/cibuildwheel` to target multiple versions of Python and different target platforms. Currently, it builds macOS 15 platform target as well as many/musl linux. Python versions 3.12 and 3.14 are also targeted for each of those (but not 3.14t).

macOS (universal2)
```bash
make release-macos
```

Linux (x86_64):
```bash
make release
```

Wheel files are output to `wheelhouse/`

Usage
------
In other repositories, you can reference this by editing `pyproject.toml`:

```toml
[[project]]
dependencies = [
"plyvel==1.5.1"
]
[[tool.uv.sources]]
plyvel = [
{ marker = "platform_system == 'Darwin'", url = "https://github.com/mattkerr-wb/plyvel/releases/download/v1.5.1/plyvel_wb-1.5.1-cp311-cp311-macosx_11_0_arm64.whl" },
  { marker = "platform_system == 'Linux'", url = "https://github.com/mattkerr-wb/plyvel/releases/download/v1.5.1/plyvel_wb-1.5.1-cp311-cp311-manylinux_2_24_x86_64.manylinux_2_28_x86_64.whl" },
#  { marker = "platform_system == 'Darwin'", url = "https://github.com/mattkerr-wb/plyvel/releases/download/v1.5.1/plyvel_wb-1.5.1-cp312-cp312-macosx_11_0_arm64.whl" },
#  { marker = "platform_system == 'Linux'", url = "https://github.com/mattkerr-wb/plyvel/releases/download/v1.5.1/plyvel_wb-1.5.1-cp312-cp312-manylinux_2_24_x86_64.manylinux_2_28_x86_64.whl" },
]
```

then:
```bash
uv sync --active
```
