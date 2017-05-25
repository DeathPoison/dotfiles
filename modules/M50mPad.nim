#[
  mPad - Dotfiles Module

  Module to install mPad for Debian Based Systems

  v0.5  - 25.05.2017 - 11:11
        - added dependencies
        - moved creation of dependencies to philanthrop

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

from threadpool import sync
from os         import fileExists, dirExists, sleep

# Handle: running commands, check status
from "../libraries/arnold/arnold"       
import runCommand, checkCommand, startCommand, isActive

# Handle: UserInput
from "../libraries/dotfile"
import askUser

# Handle: Dependencies
from "../libraries/dotfile" import checkDependencies
from "../libraries/dotfileTypes"
import DotfileModuleAttributes, Dependencies, Dependencie, command, directory, package

# Handle: Loading Spinners
from "../libraries/spinner/spinner"
import Spinner, startSpinner, stopSpinner

## Define shortcut content here ~ possibly export this content to an external file
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
let deps: Dependencies = Dependencies(
  module: "mPad",
  dependencies: @[
    Dependencie( 
      name: "NodeJS",   description: "Node JS - Javascript Engine", 
      command: "node",  kind: command 
    ),
    Dependencie( 
      name: "NPM",      description: "Node Package Manager", 
      command: "npm",   kind: command 
    ),
    Dependencie( 
      name: "Yarn",     description: "Node Package Installer", 
      command: "yarn",  kind: command  # , arguments: @[] 
    ),
    Dependencie( 
      name: "home/bin", description: "Home Bin Directory, which is linked to PATH", 
      kind: directory,  path: "/home/poisonweed/bin" 
    ),
    Dependencie(
      name: "libgconf2", description: "Configuration Database System for GNOME",
      kind: package,     package: "libgconf2-dev"
    )
  ]
)
let sp = Spinner( 
  spinner: "clock", 
  progressLabel: "Installing:",
  progressText: "VIM-Plugins: ctrlp, nerdtree, some more...",
  doneText: "DONE!", 
  abortText: "Stopped", 
  defaultDelay: 75, 
  stream: stdout 
)

let DEBUG:    bool = true ## TODO use asyncLogger
var needmPad: bool = false

var mPadDist: string = "/mPad-linux-x64"
let mPadUrl:  string = "https://github.com/DeathPoison/mpad.git"

let mPadPathShortcut: string = "/usr/share/applications/mpad.desktop"


proc install*( vars: DotfileModuleAttributes ): bool =

  # include vars like: HOME, USER, ...
  include "../buildEnvironment.nim"

  if not checkDependencies( deps, vars ):
    return false

  let mPadPath: string = HOME & r"/git/EXTERNAL/mpad"
  let mPadGitCommand:   string = r"git clone " & mPadUrl & " " & mPadPath & " 2>/dev/null"

  if checkCommand( "mpad", user = USER ):
    return true

  echo "--------------------------------------------------"
  echo "# Going to install an mpad."
  echo "--------------------------------------------------"

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

  ## build mpad
  if needmPad:
    discard runCommand( "cd " & mPadPath & " && yarn", user = USER )
    discard runCommand( "cd " & mPadPath & " && yarn run build", user = USER )
  
  ## TODO add x86, check an vm or similar to get ARCH string
  ## PS: Let's be clear, no MS Windows is supported!
  case ARCH
  of "i686", "x86":
    mpadDist = "/mPad-linux-ia32"
  of "x64", "x86_64":
    mPadDist = "/mPad-linux-x64"
  else: discard 

  ## create symlink to ~/bin
  if not fileExists( HOME & "/bin/mpad" ):
    discard runCommand( "ln -s " & mPadPath & mpadDist & "/mPad " & HOME & "/bin/mpad", user = USER )

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
    pwd:  PWD,
    arch: ARCH
  ))
