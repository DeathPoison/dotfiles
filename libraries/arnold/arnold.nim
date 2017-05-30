##[
 Library: Arnold
 ------------------------

  **"Ich bin hier um zu lenken, nicht um zu denken!"**

 Just executes System Commands - unix only?
 just a little helper for my install "script"

 ::
   v0.3 - 25.05.2017 - 14:30
        - added installPackage and installPackages

   v0.2 - added user spezific execution

   v0.1 - splittet from installer script

 :Author: **LimeBlack ~ David Crimi**
]##

#from re         import replace, re
import re
from os         import fileExists, dirExists, sleep
from osproc     import execCmdEx, execCmd
from posix      import onSignal, SIGINT, SIGTERM
from strutils   import intToStr
from threadpool import spawn, sync

## TODO create fucking nimble packages!!
from "../inception/inception" import WrongOS, CmdDoesNotExists, CmdRaisesError, CantInstallPackage

let DEBUG: bool = true # false

# TODO by adding uniq-ids to a list, i would be able to create multiple commands at once...
var shouldStop:  bool = true   
var interrupted: bool = false

## TODO need to check source files, if not available the command will not executed!

proc checkFile*( inputfile: string, isDir: bool = false ): bool =
  ## Check if File/Dir exists
  ##
  ## TODO add check if target is dir or not... dont like this argument shit!

  if DEBUG:
    echo "Checking File: " & inputfile

  if isDir:
    return dirExists( inputfile )
  else:
    return fileExists( inputfile )

proc execCommand*( 
  command: string, 
  user: string = "root", 
  wantResult: bool = false, 
  group: string = "", 
  spawed: bool = false, 
  needEnviroment: bool = false,
  raw: bool = false
): string = #  not nil
  ##[
    Executes given commands for given users

     this proc will be used by other Command-Handlers

    | raw - directly runs a command
    | wantResult - returns the result
    | needEnvironment - enables users environment
  ]##

  var usableGroup: string = group 
  if group == "":
    usableGroup = user

  if not spawed:
    shouldStop = false
  
  var commandBase = "su - " & user & " bash -c '"
  
  # add user enviroment to shell command
  if needEnviroment:
    commandBase = commandBase & "source ~/.profile;source ~/.bashrc;source ~/.bash_aliases;"
  
  if raw:
    commandBase = ""

  # su - poisonweed -c 'source ~/.profile;source ~/.bashrc;source ~/.bash_aliases; echo $PATH'
  var commandComplette = commandBase & command 

  if not raw:
    commandComplette = commandComplette & "'"

    # TODO HINT kill all errormessages here! -> should i pipe them in a log file?
    # if not wantResult:
    commandComplette = commandComplette & " 2>/dev/null"

  if DEBUG:
    echo "Run command: " & commandComplette

  var (output, exitCode) = execCmdEx commandComplette
  
  if not spawed:
    shouldStop = true

  if exitCode >= 1:
    if DEBUG: echo output
    raise newException( CmdRaisesError, intToStr(exitCode) )

  if wantResult:
    discard exitCode
    output = output.replace(re"^\s+")
    output = output.replace(re"\s+$")
    return output

  else:
    discard output
    discard exitCode


proc runCommand*( 
  command: string, 
  user: string = "root", 
  wantResult: bool = false, 
  group: string = "", 
  spawed: bool = false, 
  needEnviroment: bool = false,
  raw: bool = false
): bool =
  ##[
    | Just a wrapper to call execCommand but with a returning boolean
    | Let's name it: created a Facade for `execCommand`_
  ]##

  result = false
  try:
    discard execCommand( 
      command = command, 
      user = user, 
      wantResult = wantResult, 
      group = group, 
      spawed = spawed, 
      needEnviroment = needEnviroment,
      raw = raw
    )
    result = true
  except CmdRaisesError:
    if DEBUG:
      echo getCurrentExceptionMsg()
    result = false

proc spawnCommand*( command: string, user: string = "root", group: string = "" ) =
  ##[
    Another wrapper for execCommand, just to prevent inteferrences and illegal actions 
  ]##
  if DEBUG:
    echo "Run command: " & command

  var usableGroup: string = group 
  if group == "":
    usableGroup = user

  shouldStop = false
  #let ( output, exitCode ) = execCmdEx command
  try:
    discard execCommand( command, user = user, group = usableGroup, spawed = true )
  except CmdRaisesError:
    echo getCurrentExceptionMsg()

  shouldStop = true

  #if exitCode >= 1:
  #  if DEBUG:
  #    echo "Got an error while running the command: \n", command, output, exitCode
    # cant catch this error :( - could use a channel to populate him...
    #raise newException( CmdRaisesError, intToStr(exitCode) )

  #discard output
  #discard exitCode

proc startCommand* ( command, user: string, group: string = "" ) =
  ## | Facade for spawnCommand
  ## | isActive returns the state of this task
  var userGroup = group
  if group == "":
    userGroup = user
  
  shouldStop = false
  spawn spawnCommand( command, user = user, group = userGroup )

  ## you have to sync yourself, because this proc should not be blocking!
  ## sync()


proc validCommand*( command: string, isRaw: bool = false, user: string = "root" ): int =
  ##[
    | command hold the command you want to check
    | isRaw needs to active, to exec the unmodified command 

     | normally this method is called for single commands
     | if you want to check compex commands, and get the exitCode, use isRaw

    just return false if item is blacklisted
    elsewhere the exitCode will be returned
  ]##
  if DEBUG:
    echo "Check command: " & command

  # just return false for blacklisted items
  let blacklist: seq[ string ] = @[ "python-software-properties" ]
  for hoax in blacklist:
    if command == hoax:
      return 0

  var commandAlias = command

  # list of ( real-name, alias )
  let commandAliases: seq[(string, string)] = @[
    ( "mysql-server",           "mysql" ),
    ( "android-tools-adb",      "adb" ),
    ( "android-tools-adbd",     "adb" ),
    ( "android-tools-fastboot", "fastboot" )
  ]

  for alias in commandAliases:
    if command == alias[0]:
      commandAlias = alias[1]
      break

  if not isRaw:
    commandAlias = "type " & commandAlias

  # TODO prevent output... NOT THIS WAY: #&>/dev/null
  var output: string
  var exitCode: int = 1
  
  var commandBase = "su - " & user & " bash -c '"
  commandBase = commandBase & "source ~/.profile;source ~/.bashrc;source ~/.bash_aliases;"

  var commandFinal = commandBase & commandAlias & "'"

  (output, exitCode) = execCmdEx( commandFinal )
  
  discard output
  return exitCode

proc checkCommand* ( command: string, isRaw: bool = false, user: string = "root" ): bool =
  ## | Facade for validCommand, return [bool] true or false
  ## | an exitCode >= 1 results to false
  result = false
  let res = validCommand( command, isRaw = isRaw, user = user )
  echo "res: ", res
  if res == 0:
    result = true
  else:
    echo "INVALID COMMAND: " & command

proc isActive* (): bool =
  ## Little Helper to check if current Command is still running
  return not shouldStop


# CTRL + C
onSignal( SIGINT, SIGTERM ):
  #stdout.write "\n\nYou Pressed CTRL + C\nClosing this Application..."
  echo "" # should i send this linebreak?

  if shouldStop: # just quit if not active
    quit(130)

  interrupted = true
  sync()
  #showCursor()
  quit(130)


##### INSTALLER, possibly exclude to diffrent file...
proc installPackage*( package: string ): bool =
  ## | HINT install must be quiet!
  ## | TODO add error handling here

  var commandAlias = package

  # list of ( real-name, alias )
  let commandAliases: seq[(string, string)] = @[
    ( "node",                   "nodejs-legacy" )
  ]
  
  for alias in commandAliases:
    if package == alias[0]:
      commandAlias = alias[1]
      break

  result = true
  if not checkCommand( "dpkg --get-selections | grep \"" & commandAlias & "[[:space:]]*install$\" >/dev/null", isRaw = true ):
    echo "need to add spinners to this installation!"
    ## TODO add spinners here!
    discard execCommand( "apt install -y " & commandAlias, user = "root" )
    #HISTORY.add( "Installed package: " & commandAlias )  
    result = checkCommand( "dpkg --get-selections | grep \"" & commandAlias & "[[:space:]]*install$\" >/dev/null", isRaw = true )

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


proc runAndWaitForCommand( command: string ) =
  ## | only littl helper for testing
  ## | TODO track time and quit after a configurable timeout
  startCommand( command, user = "poisonweed" )
  
  while isActive():
    stdout.write "."
    stdout.flushFile
    sleep( 500 )

  echo ""
  sync()

when isMainModule:

  echo "cat..."
  runAndWaitForCommand "cat /proc/cpuinfo"
  echo "sleep..."
  runAndWaitForCommand( "sleep 2" )
  echo "coping..."
  runAndWaitForCommand( "cp /home/poisonweed/git/nim/sysCommand/dotfiles/libraries/arnold/grande.txt /home/poisonweed/git/nim/sysCommand/dotfiles/libraries/arnold/test.txt" )
  echo ""
  echo "Grande?"
