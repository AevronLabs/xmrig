#!/bin/sh -e

UV_VERSION="1.51.0"
mkdir -p deps/{include,lib} build && cd build

wget https://dist.libuv.org/dist/v${UV_VERSION}/libuv-v${UV_VERSION}.tar.gz -O v${UV_VERSION}.tar.gz
tar -xzf v${UV_VERSION}.tar.gz

cd libuv-v${UV_VERSION}
sh autogen.sh
./configure --disable-shared
JOBS=$(
    for f in /proc/sys/hw/ncpu /proc/sys/hw/logicalcpu; do
        [[ -f "$f" ]] && { cat "$f"; exit; }
    done
    nproc
)
make -j"$JOBS"
[ -d "include "] && [ -d "../../deps" ] || { exit 1; }
cp -a include/ ../../deps
cp .libs/libuv.a ../../deps/lib
cd ..
