#!/usr/bin/env bash
#
# Little script to bundle installation steps.
#
# v0.2 - 15.09.2018 - 03:22 - David Crimi
#      - moved to bin
#
# v0.1 - 14.05.2017 - 03:22 - David Crimi
#

DIR=$(cd "$(dirname "$0")"; pwd)

## install nim
$DIR/installNim.sh
source $DIR/../dotfiles/bash_environment
source $DIR/../dotfiles/bash_aliases

# cd $DIR/../
# nimble tasks install


cd $DIR/../src

# generate module helper
echo "Generating Modules from " `pwd`
nim c -r buildModules.nim #  &>/dev/null
rm -rf   buildModules

# run installer
echo "Run Installer"
nim c  dotfiles.nim # &>/dev/null
sudo ./dotfiles
rm -rf dotfiles

# cleanup
rm -rf nimcache

cd $DIR