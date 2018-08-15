#!/usr/bin/env bash
#
#  Nim - Dotfiles Module
#
#  Module to install Nim
#  ! nim only work if you use my .bash_alias file! ~ will be installed with installer.module.M05Dotfiles
#
#  v0.2  - 23.05.2017 - 21:00
#        - added smarter/simpler way to install nimble through koch
#
#  v0.1  - 14.05.2017 - 01:00
#        - first Version
#

echo "--------------------------------------------------------------------------------"
echo "# Going to install Nim-Lang and Nimble."
echo "--------------------------------------------------------------------------------"

CURRENT_DIR=`pwd`
DIR_GIT=$HOME"/git/.EXTERNAL"
DIR_NIM=$DIR_GIT"/Nim" # Nim/ # bin/nim

echo "Want to install/update Nim? [y/N]"
read userinput
if [ "$userinput" == "y" ] || [ "$userinput" == "Y" ]; then
  if [ -d $DIR_NIM ]; then
    nim_already_installed=true
    cd $DIR_NIM
    git pull
  else
    cd $DIR_GIT
    git clone https://github.com/nim-lang/Nim.git $DIR_NIM
  fi

  if [ "$nim_already_installed" = true ]; then
    rm -rf $DIR_NIM"/csources"
  fi

  # clone csources & build nim 
  git clone --depth 1 https://github.com/nim-lang/csources $DIR_NIM"/csources"
  cd $DIR_NIM"/csources"
  sh build.sh 1>/dev/null

  # build koch
  cd $DIR_NIM
  bin/nim c koch 1>/dev/null
  ./koch boot -d:release 1>/dev/null

  # install nimble
  ./koch nimble 1>/dev/null

  echo "need to add path, permanently"
  PATH=$PATH:$DIR_NIM/bin/
fi

## EXIT
cd $CURRENT_DIR
exit 0
