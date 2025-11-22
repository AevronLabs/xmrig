#!/bin/sh -e

LIBRESSL_VERSION="3.5.2"
mkdir -p deps/{include,lib} build && cd build

wget https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-${LIBRESSL_VERSION}.tar.gz -O libressl-${LIBRESSL_VERSION}.tar.gz
tar -xzf libressl-${LIBRESSL_VERSION}.tar.gz

cd libressl-${LIBRESSL_VERSION}
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
cp crypto/.libs/libcrypto.a ../../deps/lib
cp ssl/.libs/libssl.a ../../deps/lib
cd ..
