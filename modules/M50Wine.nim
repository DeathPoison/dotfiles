#[
  Wine - Dotfiles Module

  Module to simplify the module creation process

  v0.2  - 17.03.2018 - 16:00
        - added PKG_MNG, DIST to environment

  v0.1  - 13.05.2017 - 17:00
        - added this Module - not tested
]#

## import dotfiles helper
from "../libraries/dotfile" import askUser
from "../libraries/dotfileTypes" import DotfileModuleAttributes

# command executor
from "../libraries/arnold/arnold"
import execCommand, checkCommand, startCommand, isActive


proc install*( vars: DotfileModuleAttributes ): bool =

  # include vars like: HOME, USER, ...
  include "../buildEnvironment.nim"

  if checkCommand( "wine", user = USER ):
    return true

  echo "--------------------------------------------------"
  echo "# Going to install Wine2.0 HQ."
  echo "--------------------------------------------------"
  ## TODO https://wiki.winehq.org/Ubuntu

  if not askUser( "Really want to install Wine2.0 HQ", defaultChoice = false ):
    return false

  discard execCommand( "dpkg --add-architecture i386", user = "root" )
  discard execCommand( "cd /tmp/ && wget https://dl.winehq.org/wine-builds/Release.key && apt-key add Release.key", user = "root" )
  discard execCommand( "apt-add-repository -y https://dl.winehq.org/wine-builds/ubuntu/", user = "root" )
  discard execCommand( "apt-get update", user = "root" )
  discard execCommand( "apt-get install -y --install-recommends winehq-devel", user = "root" )


when isMainModule:

  include "../testEnvironment.nim"

  discard install(DotfileModuleAttributes(
    user: USER,
    path: PATH,
    home: HOME,
    pwd:  PWD,
    dist: DIST,
    pkg_mng: PKG_MNG
  ))