#!/bin/sh -e

OPENSSL_VERSION="1.1.1u"
mkdir -p deps/{include,lib} build && cd build

wget https://openssl.org/source/old/1.1.1/openssl-${OPENSSL_VERSION}.tar.gz -O openssl-${OPENSSL_VERSION}.tar.gz
tar -xzf openssl-${OPENSSL_VERSION}.tar.gz

cd openssl-${OPENSSL_VERSION}
./config -no-shared -no-asm -no-zlib -no-comp -no-dgram -no-filenames -no-cms
JOBS=$(
    for f in /proc/sys/hw/ncpu /proc/sys/hw/logicalcpu; do
        [[ -f "$f" ]] && { cat "$f"; exit; }
    done
    nproc
)
make -j"$JOBS"
cp -fr include ../../deps
cp libcrypto.a ../../deps/lib
cp libssl.a ../../deps/lib
cd ..
