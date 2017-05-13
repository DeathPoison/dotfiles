from os       import fileExists, dirExists, sleep, commandLineParams, getCurrentDir
from net      import newSocket, connect, Port, close
from rdstdin  import readPasswordFromStdin
from posix    import getegid, onSignal, SIGINT, SIGTERM
from tables   import toTable, keys, `[]`
from re       import re, contains, escapeRe

from threadpool import spawn, sync

# custom error types
from inception.inception 
import WrongOS, CantInstallPackage

# command executor
from arnold.arnold       
import execCommand, setOwner, validCommand, checkCommand, checkFile

from arnold.arnold       
import startCommand, spawnCommand, isActive

from inception.inception 
import CmdDoesNotExists, CmdRaisesError

# cli loading spinners
from spinner.spinner     
import Spinner, startSpinner, stopSpinner


type
  # Container for files being used by this app
  DotfileObj* = object           ## With the creation of a referenze
    name*: string
    isDir*: bool                 ## this object transforms into a
    overwrite*: bool
    target*: string              ## immutable procedure, dont need it now!
    destination*: string

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
let VERSION: string = "v0.9 - 16.04.2017 - 00:25"
let AUTHOR:  string = "LimeBlack ~ David Crimi"
var HISTORY: seq[ string ] = @[] ## TODO xD replace HISTORY with cleaner summary and add async logger


## TODO read from .env file ~ https://github.com/euantorano/dotenv.nim 
# - hint him to add namespaces           e.g.: "namespace.var = value"
# - hint him to add array  (seq[string]) e.g.: "var[] = value"
# - hint him to add hashes (table)       e.g.: "var[grande] = value"

## TODO replace concat of long text with s.th. usefull xD, iam lazy! 
## -> format or % or similar


# ask user if he really want to do: whatToDo
proc askUser*( whatToDo: string, defaultChoice: bool = true ): bool = 
  var defaultPossibilities = "[Y/n]"
  if not defaultChoice:
    defaultPossibilities = "[y/N]"

  stdout.write whatToDo & " " & defaultPossibilities & ": "
  var userChoice = stdin.readline()
  
  # set empty to true if wanted
  if defaultChoice and userChoice == "":
    userChoice = "y"

  case userChoice
  of 
    "Y", 
    "yes", 
    "y":
    result = true
  else: result = false

  HISTORY.add( "You answered with " & userChoice & " to the following question: " & whatToDo )

#[ If egid > 500 i am not a root user! ]#
proc checkRoot*(): bool = getegid() < 500

#[ Copy Method - selfExplaining! ]#
proc copy*( 
  inputfile, outputfile: string, 
  user: string = "", 
  isDir: bool = false,
  overwrite: bool = false 
): bool =
  if DEBUG:
    echo "Try copy File: " & inputfile & " to " & outputfile

  if not overwrite:
    if checkFile(outputfile, isDir = isDir ):
      let problem = "File " & outputfile & " already exists, should be overwritten?"
      if not askUser( problem, false ):
        return false
      
      echo "should overwrite"

  var copyCommand: string = "cp "
  if isDir:
    copyCommand = copyCommand & "-R "

  var command: string = copyCommand & inputfile & " " & outputfile

  if DEBUG:
    echo command

  discard execCommand( command, user = user )

  HISTORY.add( "Copied: " & inputfile & " to: " & outputfile )

  return true

proc installPackage*( package: string ): bool =
  ## HINT install must be quiet!
  ## TODO add error handling here
  result = true
  if not checkCommand( package ):
    discard execCommand( "apt install -y " & package, user = "root" )
    HISTORY.add( "Installed package: " & package )  
    result = checkCommand( package )

proc installPackages*( packages: seq[ string ] ): bool =
  ## TODO remove this misuse of exceptions here!!!
  try:
    for package in packages:
      if not installPackage( package ):
        raise newException( CantInstallPackage, "Cant install package: " & package );
  except CantInstallPackage:
    echo getCurrentExceptionMsg()
    return false
  return true

# get Processor Arch
proc getArch*(): string =
  result = execCommand( "lscpu | grep Archi | cut -d \":\" -f 2", user = "root", wantResult = true )
  #try:
  #except CmdDoesNotExists:
  #  raise newException(WrongOS, "No suitable OS found...")

# get current distribution
proc getDistribution*(): string =
  try:
    result = execCommand( "lsb_release -a 2>/dev/null | grep Distributor | cut -f 2", user = "root", wantResult = true )
  except CmdDoesNotExists:
    if DEBUG:
      echo "Command does not exists: " & getCurrentExceptionMsg()  
    result = execCommand( "uname", user = "root", wantResult = true )

# check if server is alive
proc checkServer*( host: string, port: Port = Port(80) ): bool =
  var socket = newSocket()
  try:
    socket.connect( host, port, 500 )
    socket.close()
    result = true
  except Exception:
    discard socket
    result = false


when isMainModule:
  echo "Grandehaftigkeit des Seins"