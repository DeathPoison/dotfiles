#!/usr/bin/env bash
#
# v0.1 - 15.09.2018 - 16:22 - David Crimi
#      - moved to bin

DIR=$(cd "$(dirname "$0")"; pwd)
cd ..

find . | grep '\.nim$' | while read line; do nim doc $line; done
