#[
  Vim - Dotfiles Module

  Module to install Vim for Debian Based Systems

  v1.1  - 17.03.2018 - 16:00
        - added PKG_MNG, DIST to environment

  v1.0  - 13.05.2017 - 15:11
        - first working version
        - just updates vim modules

  v0.1  - 07.05.2017 - 20:23
        - just a stab
]#

from os       import fileExists, dirExists, sleep
#from re       import re, contains, escapeRe
import re

from threadpool import spawn, sync

from "../libraries/arnold/arnold"
import execCommand, checkCommand
## setOwner, validCommand, checkFile

from "../libraries/arnold/arnold"
import startCommand, spawnCommand, isActive

# cli loading spinners
from "../libraries/spinner/spinner"
import Spinner, startSpinner, stopSpinner

## import dotfiles helper
from "../libraries/dotfile"
import askUser

from "../libraries/dotfile" import checkDependencies
from "../libraries/dotfileTypes"
import DotfileObj, DotfileModuleAttributes, Dependencies, Dependencie, command, directory


## define your dependencies
let deps: Dependencies = Dependencies(
  module: "Vim",
  dependencies: @[
    Dependencie(
      name: "vim", description: "VIM Improved Version of VI ~ a CLI-Based Text Editor",
      kind: command,  command: "vim"
    ),
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
let DEBUG = true ## TODO use asyncLogger


proc install*( vars: DotfileModuleAttributes ): bool =

  # include vars like: HOME, USER, ...
  include "../buildEnvironment.nim"

  if not checkDependencies( deps, vars ):
    return false

  echo "--------------------------------------------------"
  echo "# Going to install an VIM with Plugins."
  echo "--------------------------------------------------"

  stdout.write "Installing VIM-Plugins: "
  startCommand( "vim +PluginInstall +qall", user = USER )
  spinner.spawnSpinner sp

  while isActive():       # while command is running: wait!  ~ could do sync here, but... this way iam able to include dirty hacks like set position after spinner and display some text there... iam not going to do this!!!
    sleep( 200 )

  spinner.stopSpinner()   # stop spinnerThread
  sync()                  # make sure threads are finished @spinner, arnold



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
