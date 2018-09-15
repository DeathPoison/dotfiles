#[
  Github - Dotfiles Module

  Module to install Git

  v0.3  - 17.03.2018 - 16:00
        - added PKG_MNG, DIST to environment

  v0.2  - 25.05.2017 - 14:30
        - added dependencies

  v0.1  - 13.05.2017 - 15:00
        - added a simple base Module
]#

## import dotfiles helper
from "../libraries/dotfileHelper" import askUser

from "../libraries/arnold/arnold"
import execCommand, checkCommand

from "../libraries/dotfileHelper" import checkDependencies
from "../libraries/dotfileTypes"
import DotfileObj, DotfileModuleAttributes, Dependencies, Dependencie, command, directory


## define your dependencies
let deps: Dependencies = Dependencies(
  module: "dotfiles",
  dependencies: @[
    Dependencie(
      name: "git", description: "Git Version Control System",
      kind: command,  command: "git"
    ),
  ]
)


proc install*( vars: DotfileModuleAttributes ): bool =

  # include vars like: HOME, USER, ...
  include "../libraries/buildEnvironment.nim"

  if not checkDependencies( deps, vars ):
    return false


  echo "--------------------------------------------------"
  echo "# Going to configure Github for you."
  echo "--------------------------------------------------"

  let haveUsername: bool = checkCommand("git config --global user.name")
  let haveEmail:    bool = checkCommand("git config --global user.email")

  if haveEmail and haveUsername:
    return false

  echo "--------------------------------------------------"
  echo "# Going to configure Git."
  echo "--------------------------------------------------"
  if not askUser( "Want git?", defaultChoice = false ):
    return false

  if not haveUsername:
    discard execCommand( "git config --global user.name " & USER, user = USER )

  if not haveEmail:
    stdout.write("Give my an email for your config: ")
    let email = stdin.readLine()
    discard execCommand( "git config --global user.email " & email, user = USER )

proc uninstall*( vars: DotfileModuleAttributes ): bool =
  include "../libraries/buildEnvironment.nim"
  echo "Goin to remove M20Git Module"

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