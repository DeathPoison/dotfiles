#[

  Philanthrop Lib

  just a little helper for broken dependencies of my modules

  # ! This lib requires the usage of a local .bashrc

  v0.1 - 25.05.2017 - 14:30
       - init version
       - added generic handlers for directories and commands 
       - added fix for home/bin directory
]#


from os       import fileExists, dirExists, sleep, commandLineParams, getCurrentDir
from net      import newSocket, connect, Port, close
from rdstdin  import readPasswordFromStdin
from posix    import getegid, onSignal, SIGINT, SIGTERM
from tables   import toTable, keys, `[]`

from strutils import join
#from re       import re, contains, escapeRe
import re

from threadpool import spawn, sync

# custom error types
from inception.inception 
import WrongOS, CantInstallPackage

# command executor
from arnold.arnold       
import execCommand, setOwner, validCommand, checkCommand, checkFile, runCommand, installPackage

from arnold.arnold       
import startCommand, spawnCommand, isActive

from inception.inception 
import CmdDoesNotExists, CmdRaisesError

# cli loading spinners
from spinner.spinner     
import Spinner, startSpinner, stopSpinner

from dotfileTypes 
import DotfileObj, DotfileModuleAttributes,  DependencieType, Dependencie, Dependencies


## TODO clean imports!
let DEBUG = false


proc fixHomeBin( USER: string, HOME: string, PATH: string ): bool =
  result = false
  
  ## make sure home/bin exists
  let homeBin: string = HOME & r"/bin"
  if not dirExists( homeBin ):
    discard runCommand( "mkdir " & homeBin, user = USER )

  ## make sure ~/bin dir exists and is in PATH
  if not PATH.contains( re escapeRe( homeBin ) ):
    ## TODO need to make sure this wont be added twice
    echo "check bashrc end for export path!"
    if DEBUG:
      echo "add " & HOME & "/bin to $PATH"
    result = runCommand( """echo "export PATH=\$PATH:""" & HOME & "/bin\" >> " & HOME & "/.bashrc", user = USER )
  else:
    echo HOME & "/bin found in PATH"
    result = true  

proc fixDirectory( PATH: string, USER: string ): bool =
    result = false

    if not dirExists( PATH ):
      result = runCommand( "mkdir " & PATH & " 2>/dev/null", user = USER ) 
    
##### fix several problems without any module managment...
proc tryToFix*( dependencie: Dependencie, vars: DotfileModuleAttributes ): bool =
  result = false
  echo "try'in to fix this shit", dependencie

  # include vars like: HOME, USER, ...
  include "../buildEnvironment.nim"

  ## add few ( hopefully ) helpful fixes
  case dependencie.name
  of "home/bin":
    result = fixHomeBin( USER = USER, HOME = HOME, PATH = PATH )
  else: discard

  # now its gonna be ugly! - generic error handling... have to be the BEST idea!
  if not result:
    case dependencie.kind
    of directory:
      result = fixDirectory( PATH = PATH, USER = USER )
    of command:
      case dependencie.command
      of "yarn":
        if runCommand( "npm install -g yarn" ):
          if not fileExists("/usr/bin/yarn"):
            discard runCommand("ln -s /usr/local/bin/yarn /usr/bin/yarn")):
          result = true

      else: 
        result = installPackage( dependencie.command )
    else: discard

  ## no fix found!
