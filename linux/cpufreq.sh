#!/bin/bash

CPUINFO_MIN_FREQ=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq)
CPUINFO_MAX_FREQ=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)
MIN=$(echo "scale=1; $CPUINFO_MIN_FREQ / 1000000" | bc)"G"
MAX=$(echo "scale=1; $CPUINFO_MAX_FREQ / 1000000" | bc)"G"

echo "Minimum frequency: $MIN, Maximum frequency: $MAX"

GOVERNOR=@0
if [ $# -eq 0 ]; then
	echo "No arguments supplied, using governor: performance"
	GOVERNOR="performance"
else
	echo "Governor $1 supplied"
	GOVERNOR=$1
fi

NCORE="$(nproc)"
echo "Setting all ($NCORE) cores to use governor: $GOVERNOR"

for ((i = 0; i < "$NCORE"; i++)); do
	cpufreq-set -c $i -r -g "$GOVERNOR" --min "$MIN" --max "$MAX"
done

echo "set governor $GOVERNOR on $NCORE cores"
