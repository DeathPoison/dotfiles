#[
  Terminology - ELF Terminal - Dotfiles Module

  Module to install the Terminology Terminal

  v0.1  - 13.05.2017 - 16:00
        - added this Module
  
  Author: LimeBlack ~ David Crimi
]#

## import dotfiles helper
from "../libraries/dotfile" import DotfileModuleAttributes, askUser, installPackage

from "../libraries/arnold/arnold"       
import execCommand, checkCommand


proc install*( vars: DotfileModuleAttributes ): bool =

  # include vars like: HOME, USER, ...
  include "../buildEnvironment.nim"

  if checkCommand( "terminology" ): return false

  echo "--------------------------------------------------"
  echo "# Going to install the Terminology Terminal."
  echo "--------------------------------------------------"
  let sure: string = "Do you really want to add a PPA and install Terminology?"

  if not askUser( sure, defaultChoice = false ): 
    return false

  discard execCommand( "add-apt-repository -y ppa:enlightenment-git/ppa", user = "root" )
  discard execCommand( "apt update", user = "root" )
  if installPackage( "terminology" ):
    if not SILENT:
      echo "successfully installed Terminology"


when isMainModule:
  
  include "../testEnvironment.nim"
  
  discard install(DotfileModuleAttributes(
    user: USER,
    path: PATH,
    home: HOME,
    pwd:  PWD
  ))