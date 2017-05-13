#[
  Vim - Dotfiles Module

  Little module to install Vim for Debian Based Systems

  v0.1  - 07.05.2017 - 20:23 
        - just a stab
]#

## TODO clean this imports xD
from os       import fileExists, dirExists

from tables   import `[]`, Table

from re       import re, contains, escapeRe

from "../libraries/arnold/arnold"       
import execCommand, checkCommand
## setOwner, validCommand, checkFile

#from "../libraries/arnold/arnold"       
#import startCommand, spawnCommand, isActive

#from "../libraries/inception/inception" 
#import CmdDoesNotExists, CmdRaisesError

# cli loading spinners
#from "../libraries/spinner/spinner"     
#import Spinner, startSpinner, stopSpinner

## import dotfiles helper
# askUser
from "../libraries/dotfile"
import askUser
#DotfileObj, checkRoot, copy, installPackage, installPackages, getArch, getDistribution, checkServer


let DEBUG = true ## TODO use asyncLogger

proc install*( vars: Table[string, string] ): bool =

  echo "vim!"
  return true
#[
  let USER = vars["USER"]
  let HOME = vars["HOME"]
  let PATH = vars["PATH"]

  if checkCommand( "mpad", user = USER ):
    return true

  echo "--------------------------------------------------"
  echo "# Going to install an VIM with Plugins."
  echo "--------------------------------------------------"

  echo "NOT READY YET!!!"
]#


proc testNanzi*() =
  echo "Aber Nanzi!"

when isMainModule:
  #install({"USER":"poisonweed"}.toTable)
  echo "grande"

