#[
  mPad - Dotfiles Module

  Module to install mPad for Debian Based Systems

  v0.4  - 13.05.2017 - 23:15
        - fully working and tested!

  v0.3  - 13.05.2017 - 15:11
        - changed attributes to object, now its possible to add booleans
        - added runlevel to modules
        - begin to exclude the single modules from installer, looks very good for now!

  v0.2  - 13.05.2017 - 03:59
        - will be executed

        - need to finish build process of mpad
        - but this modules will be executed finely
        - probaby i should add some error types 
        - need a proc to check given vars

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
]#

from os       import fileExists, dirExists, sleep
from re       import re, contains, escapeRe
from threadpool import sync

# command executor
from "../libraries/arnold/arnold"       
import execCommand, checkCommand, startCommand, isActive

## import dotfiles helper
from "../libraries/dotfile"
import askUser, DotfileModuleAttributes

# cli loading spinners
from "../libraries/spinner/spinner"     
import Spinner, startSpinner, stopSpinner


let DEBUG = true ## TODO use asyncLogger
let shortcut: string = """
[Desktop Entry]
Name=mPad
Comment=Markdown Editor
Exec=mpad %f
MimeType=text/markdown
Type=Application
StartupNotify=true
Terminal=false
Categories=Editor;Markdown;Text;Electron;Vue;Webkit;
"""
let sp = Spinner( 
  spinner: "clock", 
  progressLabel: "Installing:",
  progressText: "VIM-Plugins: ctrlp, nerdtree, some more...",
  doneText: "DONE!", 
  abortText: "Stopped", 
  defaultDelay: 75, 
  stream: stdout 
)
let mPadUrl: string = "https://github.com/DeathPoison/mpad.git"
let mPadPathShortcut: string = "/usr/share/applications/mpad.desktop"
var needmPad: bool = false

proc install*( vars: DotfileModuleAttributes ): bool =

  # include vars like: HOME, USER, ...
  include "../buildEnvironment.nim"

  let mPadPath: string = HOME & r"/git/EXTERNAL/mpad"
  let mPadGitCommand: string = r"git clone " & mPadUrl & " " & mPadPath & " 2>/dev/null"

  # make sure yarn is installed
  if not checkCommand( "yarn", user = USER ):
    if DEBUG:
      echo "need yarn to build mPad!"
    return false

  if checkCommand( "mpad", user = USER ):
    return true

  echo "--------------------------------------------------"
  echo "# Going to install an mpad."
  echo "--------------------------------------------------"

  echo "NOT READY YET!!!"

  if not askUser( "Want to install mpad?", defaultChoice = true ):
    return false

  # clone git dir
  if not dirExists( mPadPath ):
    needmPad = true
    startCommand( mPadGitCommand, user = USER )

    spinner.spawnSpinner sp
    while isActive():       # while command is running: wait!  ~ could do sync here, but... this way iam able to include dirty hacks like set position after spinner and display some text there... iam not going to do this!!!
      sleep( 200 )
    
    spinner.stopSpinner()   # stop spinnerThread
    sync()                  # make sure threads are finished @spinner, arnold
    #discard execCommand( mPadGitCommand, user = USER )

  ## make sure ~/bin dir exists and is in PATH
  if not PATH.contains( re escapeRe( HOME & r"/bin" ) ):
    if DEBUG:
      echo "add " & HOME & "/bin to $PATH"
    discard execCommand( """echo "export PATH=$PATH:""" & HOME & "/bin\" >> " & HOME & "/.bashrc", user = USER )
  else:
    echo HOME & "/bin found in PATH"

  ## build mpad
  if needmPad:
    discard execCommand( "cd " & mPadPath & " && yarn", user = USER )
    discard execCommand( "cd " & mPadPath & " && yarn run build", user = USER )
  
  ## create symlink to ~/bin
  if not fileExists( HOME & "/bin/mpad" ):
    discard execCommand( "ln -s " & mPadPath & "/mPad-linux-x64/mPad " & HOME & "/bin/mpad", user = USER )

  ## create desktop link
  if not fileExists( mPadPathShortcut ):
    let shortcutFile = open(mPadPathShortcut, fmWrite)
    shortcutFile.write(shortcut)
    shortcutFile.close

when isMainModule:

  include "../testEnvironment.nim"

  discard install(DotfileModuleAttributes(
    user: USER,
    path: PATH,
    home: HOME,
    pwd:  PWD
  ))

