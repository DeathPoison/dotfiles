#[
  Github - Dotfiles Module

  Module to install Git

  v0.1  - 09.08.2017 - 23:00
        - adding i3-gaps with usefull config
]#

from threadpool import sync
from os import fileExists, dirExists, sleep

## import dotfiles helper
from "../libraries/dotfile" import askUser

# Handle: running commands, check status
from "../libraries/arnold/arnold"
import execCommand, checkCommand, startCommand, runCommand, installPackage, installPackages, isActive

# Handle: Dependencies
from "../libraries/dotfile" import checkDependencies
from "../libraries/dotfileTypes"
import DotfileObj, DotfileModuleAttributes, Dependencies, Dependencie, package, command, directory

# Handle: Loading Spinners
from "../libraries/spinner/spinner"
import Spinner, startSpinner, stopSpinner


var needi3:   bool = false
let i3Url:    string = "https://github.com/Airblader/i3"
#let i3Status: string = "https://github.com/XYunknown/i3status-rust.git"

let sp = Spinner(
  spinner: "clock",
  progressLabel: "Installing:",
  progressText: "VIM-Plugins: ctrlp, nerdtree, some more...",
  doneText: "DONE!",
  abortText: "Stopped",
  defaultDelay: 75,
  stream: stdout
)

proc install*( vars: DotfileModuleAttributes ): bool =

  # include vars like: HOME, USER, ...
  include "../buildEnvironment.nim"

  let i3Path: string = HOME & r"/git/.EXTERNAL/i3-gaps"
  #let i3StatusPath: string = HOME & r"/git/.EXTERNAL/i3status-rust"
  let i3GitCommand: string = r"git clone " & i3Url & " " & i3Path & " 2>/dev/null"
  #let i3StatusCommand: string = r"git clone " & i3Status & " " & i3StatusPath & " 2>/dev/null"

  ## define your dependencies
  let deps: Dependencies = Dependencies(
    module: "dotfiles",
    dependencies: @[
      #Dependencie(
      #  name: "cargo", description: "Cargo Rust Compiler",
      #  kind: command,  command: "cargo", user: USER
      #),
      Dependencie(
        name: "scrot", description: "Scrot SCReenshOT",
        kind: package,  package: "scrot"
      ),
      Dependencie(
        name: "rofi", description: "Rofi Application Launcher",
        kind: package,  package: "rofi"
      ),
      Dependencie(
        name: "feh", description: "Feh Image Handler",
        kind: package,  package: "feh"
      ),
      Dependencie(
        name: "compton", description: "Compton Window Transitions",
        kind: package,  package: "compton"
      ),
    ]
  )

  if dirExists( i3Path ):
    if not askUser( "Reinstall i3?", defaultChoice = true ):
      return true # already installed

  echo "--------------------------------------------------"
  echo "# Going to configure i3-gaps for you."
  echo "--------------------------------------------------"

  if not askUser( "Want i3-gaps?", defaultChoice = true ):
    return false

  if not checkDependencies( deps, vars ):
    return false


  if not dirExists( i3Path ):
    startCommand( i3GitCommand, user = USER )
    spinner.spawnSpinner sp
    while isActive():       # while command is running: wait!  ~ could do sync here, but... this way iam able to include dirty hacks like set position after spinner and display some text there... iam not going to do this!!!
      sleep( 200 )

    spinner.stopSpinner()   # stop spinnerThread
    sync()                  # make sure threads are finished @spinner, arnold


  #if not dirExists( i3StatusPath ):
  #  startCommand( i3StatusCommand, user = USER )
  #  spinner.spawnSpinner sp
  #  while isActive():       # while command is running: wait!  ~ could do sync here, but... this way iam able to include dirty hacks like set position after spinner and display some text there... iam not going to do this!!!
  #    sleep( 200 )

  #  spinner.stopSpinner()   # stop spinnerThread
  #  sync()                  # make sure threads are finished @spinner, arnold


  let grandeDeps: seq[string] = @[
    "libxcb1-dev", "libxcb-keysyms1-dev", "libpango1.0-dev", "libxcb-util0-dev",
    "libxcb-icccm4-dev", "libyajl-dev", "libstartup-notification0-dev",
    "libxcb-randr0-dev", "libev-dev", "libxcb-cursor-dev", "libxcb-xinerama0-dev",
    "libxcb-xkb-dev", "libxkbcommon-dev", "libxkbcommon-x11-dev", "autoconf", "libxcb-xrm-dev",
    "i3", "rofi", "feh", "compton"
  ]
  var blacklist: seq[string] = @[]

  #if DIST == "Raspbian":
  #  blacklist.add("libxcb1-dev")

  discard installPackages( grandeDeps, packageManager = PKG_MNG, distribution = DIST, blacklist = blacklist )

  ## compile status bar ~ rust
  #discard runCommand( "cd " & i3StatusPath & " && cargo build --release", user = USER )

  ## compile i3-gaps
  discard runCommand( "cd " & i3Path & " && autoreconf --force --install", user = USER )
  discard runCommand( "cd " & i3Path & " && mkdir -p build", user = USER )
  discard runCommand( "cd " & i3Path & "/build && ../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers", user = USER )
  ## FIXME replace cpu count
  discard runCommand( "cd " & i3Path & "/build && make -j1", user = USER )
  discard runCommand( "cd " & i3Path & "/build && make install", user = "root" )


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
