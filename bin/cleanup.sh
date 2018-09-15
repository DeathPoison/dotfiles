#!/usr/bin/env bash
#
# v0.1 - 15.09.2018 - 16:22 - David Crimi
#      - created to clean project dir
#      - moved to bin

DIR=$(cd "$(dirname "$0")"; pwd)

rm -rf $DIR/../src/dotfiles                # compiled
rm -rf $DIR/../src/buildModules            # compiled
rm -rf $DIR/../src/importModules.nim       # generated
rm -rf $DIR/../src/importModules.nim.cfg   # generated
rm -rf $DIR/../src/installModules          # compiled
rm -rf $DIR/../src/installModules.nim      # generated
rm -rf $DIR/../src/uninstallModules        # compiled
rm -rf $DIR/../src/uninstallModules.nim    # generated
rm -rf $DIR/../src/nimcache                # cache
rm -rf $DIR/../modules/*.cfg               # generated

$DIR/removeDoc.sh

## purge libraries symlink?
