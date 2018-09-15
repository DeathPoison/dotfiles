#!/usr/bin/env bash
#
# v0.1 - 15.09.2018 - 03:22 - David Crimi
#      - moved to bin

DIR=$(cd "$(dirname "$0")"; pwd)

find $DIR/../src/ | grep --color=no .html$
if [ $? -eq 0 ]; then
  find $DIR/../src/ | grep --color=no .html$ | xargs rm
fi