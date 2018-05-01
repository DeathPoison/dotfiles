#!/usr/bin/env bash
#
# Little script to bundle installation steps.
# 
# v0.1 - 14.05.2017 - 03:22 - David Crimi
#

./installNim.sh
source dotfiles/bash_aliases

nim c -r buildModules.nim &>/dev/null
nim c installer.nim &>/dev/null

sudo ./installer