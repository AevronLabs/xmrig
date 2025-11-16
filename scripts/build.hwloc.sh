#!/bin/sh -e

HWLOC_VERSION_MAJOR="2"
HWLOC_VERSION_MINOR="12"
HWLOC_VERSION_PATCH="1"

HWLOC_VERSION="${HWLOC_VERSION_MAJOR}.${HWLOC_VERSION_MINOR}.${HWLOC_VERSION_PATCH}"

mkdir -p deps/{include,lib} build && cd build

wget https://download.open-mpi.org/release/hwloc/v${HWLOC_VERSION_MAJOR}.${HWLOC_VERSION_MINOR}/hwloc-${HWLOC_VERSION}.tar.gz -O hwloc-${HWLOC_VERSION}.tar.gz
tar -xzf hwloc-${HWLOC_VERSION}.tar.gz

cd hwloc-${HWLOC_VERSION}
./configure --disable-shared --enable-static --disable-io --disable-libudev --disable-libxml2
JOBS=$(
    for f in /proc/sys/hw/ncpu /proc/sys/hw/logicalcpu; do
        [ -f "$f" ] && { cat "$f"; exit; }
    done
    nproc
)
make -j"$JOBS"

cp -a include/. ../../deps/include/

# not a great idea to use -rf...
cp hwloc/.libs/libhwloc.a ../../deps/lib
cd ..
