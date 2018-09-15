#!/usr/bin/env bash
#
# v0.1 - 15.09.2018 - 16:22 - David Crimi
#      - moved to bin

DIR=$(cd "$(dirname "$0")"; pwd)
cd ..

echo "Counting following files:"
find $DIR/../ -name "*.nim" | grep -v nimcache | grep -v '\./dot' | grep -v '\.git' | grep -v '\.cfg' | xargs cat | wc -l

## Histroy
#
# - 15.09.2018 - 1427