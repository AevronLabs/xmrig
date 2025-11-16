#!/bin/sh -e

# https://xmrig.com/docs/miner/hugepages#onegb-huge-pages

for f in /proc/sys/hw/ncpu /proc/sys/hw/logicalcpu; do
    [ -f "$f" ] && { CPUS=$(cat "$f"); break; }
done
: "${CPUS:=$(nproc)}"

command -v sysctl >/dev/null 2>&1 && sysctl -w vm.nr_hugepages="$CPUS"

for n in /sys/devices/system/node/node*; do
    [ -d "$n/hugepages/hugepages-1048576kB" ] && \
    echo 3 > "$n/hugepages/hugepages-1048576kB/nr_hugepages"
done

echo "1GB pages enabled."