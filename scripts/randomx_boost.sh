#!/bin/sh
set -e

# Enable MSR writes
[ -e /sys/module/msr/parameters/allow_writes ] && echo on > /sys/module/msr/parameters/allow_writes || modprobe msr allow_writes=on

# Detect CPU
CPUINFO=$(cat /proc/cpuinfo)
if echo "$CPUINFO" | grep -Eq 'AMD Ryzen|AMD EPYC|AuthenticAMD'; then
    FAMILY=$(echo "$CPUINFO" | awk '/cpu family/ {print $4; exit}')
    MODEL=$(echo "$CPUINFO" | awk '/model/ {print $3; exit}')
    case "$FAMILY" in
        25) [ "$MODEL" = "97" ] && echo "Zen4" && wrmsr -a 0xc0011020 0x4400000000000 -a 0xc0011021 0x4000000000040 -a 0xc0011022 0x8680000401570000 -a 0xc001102b 0x2040cc10 || echo "Zen3" && wrmsr -a 0xc0011020 0x4480000000000 -a 0xc0011021 0x1c000200000040 -a 0xc0011022 0xc000000401570000 -a 0xc001102b 0x2000cc10 ;;
        26) echo "Zen5" && wrmsr -a 0xc0011020 0x4400000000000 -a 0xc0011021 0x4000000000040 -a 0xc0011022 0x8680000401570000 -a 0xc001102b 0x2040cc10 ;;
        *)  echo "Zen1/Zen2" && wrmsr -a 0xc0011020 0 -a 0xc0011021 0x40 -a 0xc0011022 0x1510000 -a 0xc001102b 0x2000cc16 ;;
    esac
elif echo "$CPUINFO" | grep -q "Intel"; then
    echo "Intel" && wrmsr -a 0x1a4 0xf
else
    echo "No supported CPU"
fi
