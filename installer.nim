#[

  Dotfiles

  Script to create my linux enviroment

  Before running this script, you need to execute: buildModules

  Date: 10.04.2017 - 00:15 - v0.7
  Author: LimeBlack ~ David Crimi
]#

from os     import commandLineParams, getCurrentDir
from posix  import onSignal, SIGINT, SIGTERM 

from threadpool import sync

# custom error types
from libraries.inception.inception 
import WrongOS

# command executor
from libraries.arnold.arnold       
import execCommand, checkCommand

## import dotfiles helper
from libraries.dotfile
import askUser, checkRoot, getArch, getDistribution, checkServer, DotfileModuleAttributes


var DEBUG: bool = false
let HELP: string = """
  
  Dotfile Installer

  Argument:          Description:
  "-s", "--silent"   silent mode - less output
  "-d", "--debug"    debug  mode - more output
  "-f", "--force"    force  mode - overwrite all files   
  "-h", "--help"     this help text
  "-v", "--version"  show version
"""
let SUCCESS: string = """
##################################################
# Successfully installed, here comes the Summary:
#
##################################################
"""
let VERSION: string = "v0.9 - 16.04.2017 - 00:25"
let AUTHOR:  string = "LimeBlack ~ David Crimi"
var PATH:    string = "" #os.getEnv("PATH") ## TODO probably i need to use arnold to get the corrent enviroment
var HOME:    string = "" # /home/poisonweed
var USER:    string = "" # your used user -> install packages and enviroment for him!

var MODULES: seq[ string ] = @[] # hold list of available modules
var HISTORY: seq[ string ] = @[] ## TODO xD replace HISTORY with cleaner summary and add async logger
var PWD:     string  # working dir 
var ARCH:    string  # used arch eg: x86_64
var DIST:    string  # used dist eg: Ubuntu or Debian
var SILENT:  bool    # ask questions?
var FORCE:   bool    # should overwrite all?
# TODO var PKG_MNG: string  # used package manager: only apt and apt-get for now!

## cant check if file exists, compiler stops compiling anyway
include "importModules.nim"
echo MODULES

proc buildSummary(): string = 
  result = SUCCESS
  for event in HISTORY:
    result = result & event & "\n"
  result = result & "##################################################"

proc stopApplication( 
  message: string = "\n\nGo'in to stop this Application",
  exitcode: int = 0
) = 
  echo message
  sync()
  HISTORY.add( "Closed Application" )
  quit(exitcode)

## TODO wanna fetch ctrl+d, but: CTRL+D is not a signal, it's EOF (End-Of-File). It closes the stdin pipe.
# CTRL + C
onSignal( SIGINT, SIGTERM ):
  
  var msg: string = ""
  if not (SILENT or FORCE):
    msg = "\n\nYou Pressed CTRL + C"

  HISTORY.add( "You interrupted the application with CTRL + C" )
  stopApplication( message = msg, exitcode = 130 )


## START ################################
when isMainModule:

  ## TODO: create a NIM installer in Bash! ~ replace with M20Nim Module
  echo "create a NIM installer in Bash!"

  # check cli-params
  when declared(commandLineParams):
    for param in commandLineParams():
      case param
      of "-s", "--silent":
        SILENT = true
      of "-f", "--force":
        FORCE = true
      of "-d", "--debug":
        DEBUG = true
      of "-h", "--help":
        echo HELP
        echo "  Version: ", VERSION
        echo "  Author:  ",  AUTHOR
        stopApplication( message = ""   )
      of "-v", "--version":
        echo "Version: ", VERSION
        echo "Author:  ",  AUTHOR
        stopApplication( message = ""   )
      else:
        continue

  if not checkRoot():
    echo "try again as root user!"
    quit(1)

  if not checkServer( host = "heise.de" ):
    echo "you need an internet connection!"
    stopApplication( exitCode = 1 )
  
  try:
    ARCH = getArch()
  except WrongOS:
    echo "ERROR"
    echo getCurrentExceptionMsg()
    stopApplication( exitCode = 1 )

  # TODO add multiple package-managers
  if not checkCommand("apt") or not checkCommand("apt-get"):
    stopApplication( exitCode = 1 )

  # TODO add error handling
  DIST = getDistribution()
  PWD  = os.getCurrentDir() # execCommand( "pwd", wantResult = true )

  stdout.write( "\nPlease enter your Username: [poisonweed]" )
  USER = stdin.readline()

  if USER == "":
    USER = "poisonweed"

  HOME = "/home/" & USER
  if USER == "root":
    HOME = "/root"

  PATH = execCommand( "echo $PATH", user = USER, wantResult = true, needEnviroment = true )

  # print fetched environment infos
  block checkSetup:  
    if SILENT or FORCE:
      break checkSetup

    var enviroment: string = "" & 
      "---------------------------" & "\n" &
      "Your entered  User: " & USER & "\n" &
      "Your detected Arch: " & ARCH & "\n" &
      "Your detected Dist: " & DIST & "\n" &
      "Your detected Home: " & HOME & "\n" &
      "Your detected PWD:  " & PWD  & "\n" &
      "---------------------------"

    echo enviroment

    if not askUser( "Want to proceed? Check the detected Enviroment above!", defaultChoice = true ):
      quit(1)

  # install all modules
  include "installModules.nim"

  echo buildSummary()
  stopApplication()
