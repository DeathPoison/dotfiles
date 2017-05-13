#[
  mPad - Dotfiles Module

  Little module to install mPad for Debian Based Systems

  Checklist for Modules:

  - need implemented install proc
  - need table with VARS ~ replace with install attributes

  v0.1  - 01.05.2017 - 00:32 
        - first Version

        - goin to create modules... should be much nicer xD
        - they should be executable as single instance or as module
        - they should not be async, because of user interaction - or i implement a queue and some locking
        - for now i have to create a little dotfile helper library to use listed proc's
        - i should give the VARS as arguments 
        - for single use i should implement some command line arguments ~ BEWARE SILENT and FORCE mode!
        - THIS FILE WAS NEVER BEEN TESTED, EXECUTED OR COMPILED...NOR SINGLE NOR AS MODULE!
        - the module import does not even exist...

  v0.2  - 13.05.2017 - 03:59
        - will be executed

        - need to finish build process of mpad
        - but this modules will be executed finely
        - probaby i should add some error types 
        - need a proc to check given vars
]#

## TODO need to import: 

## TODO clean this imports xD
# dirExists
from os       import fileExists, dirExists
# sleep, commandLineParams, getCurrentDir

#from net      import newSocket, connect, Port, close
#from rdstdin  import readPasswordFromStdin
#from posix    import getegid, onSignal, SIGINT, SIGTERM

from tables   import `[]`, Table
#toTable, keys, 

from re       import re, contains, escapeRe

#from threadpool import spawn, sync

# custom error types
#from "../libraries/inception/inception" 
#import WrongOS, CantInstallPackage

# command executor
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



## VARS needed:
# USER
# HOME
# PATH
let DEBUG = true ## TODO use asyncLogger

## block createMPad:

#proc install*( user: string, home: string, path: string ): bool =
proc install*( vars: Table[string, string] ): bool =

  try:
    echo "need to check if vars exists"
  except:
    return false

  let USER = vars["USER"]
  let HOME = vars["HOME"]
  let PATH = vars["PATH"]

  #if checkCommand( "mpad", user = USER ):
  #  return true

  echo "--------------------------------------------------"
  echo "# Going to install an mpad."
  echo "--------------------------------------------------"

  echo "NOT READY YET!!!"

  if not askUser( "Want to install mpad?", defaultChoice = true ):
    return false

  let mPadUrl: string = "https://github.com/DeathPoison/mpad.git"
  let mPadPath: string = r"/git/EXTERNAL/mpad"
  let mPadGitCommand: string = r"git clone " & mPadUrl & " " & HOME & mPadPath & " 2>/dev/null"

  if not dirExists( HOME & mPadPath ):
    discard execCommand( mPadGitCommand, user = USER )

  ## TODO make sure ~/bin dir exists and is in PATH
  if not PATH.contains( re escapeRe( HOME & r"/bin" ) ):
    if DEBUG:
      echo "add " & HOME & "/bin to $PATH"
    discard execCommand( "PATH=$PATH:" & HOME & r"/bin", user = USER )
  else:
    echo HOME & "/bin found in PATH"

  ## build mpad
  ## create symlink to ~/bin
  ## create desktop link

when isMainModule:

  import os, tables

  include "../testEnvironment.nim"

  discard install({"USER":USER, "PATH":PATH, "HOME":HOME, "PWD":PWD}.toTable)
  echo "grande"

