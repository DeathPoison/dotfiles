#[
  OpenSSH Module - Dotfiles Module

  Module to simplify the module creation process

  v0.3  - 17.03.2018 - 16:00
        - added PKG_MNG, DIST to environment

  v0.2  - 25.05.2017 - 14:30
        - added dependencies

  v0.1  - 13.05.2017 - 16:30
        - added this Module
]#

## import dotfiles helper
from os import fileExists
from terminal import readPasswordFromStdin
#from rdstdin  import readPasswordFromStdin
from "../libraries/dotfileHelper" import askUser

from "../libraries/arnold/arnold"
import execCommand, checkCommand, installPackage

from "../libraries/dotfileHelper" import checkDependencies
from "../libraries/dotfileTypes"
import DotfileObj, DotfileModuleAttributes, Dependencies, Dependencie, command, directory


## define your dependencies
let deps: Dependencies = Dependencies(
  module: "OpenSSH",
  dependencies: @[
    Dependencie(
      name: "xclip", description: "xClip using Clipboard from CLI",
      kind: command,  command: "xclip"
    ),
  ]
)
let DEBUG = false ## TODO use asyncLogger


proc install*( vars: DotfileModuleAttributes ): bool =

  # include vars like: HOME, USER, ...
  include "../libraries/buildEnvironment.nim"

  if not checkDependencies( deps, vars ):
    return false

  echo "--------------------------------------------------"
  echo "# Going to install an OpenSSH Server."
  echo "--------------------------------------------------"
  var freshInstallation: bool = false

  ## TODO create shortcut to break from ssh ~ for the user

  block createSSHServer_application:
    if checkCommand( "ls /etc/init.d/openssh", isRaw = true ):
      break createSSHServer_application

    if checkCommand( "ls /etc/init.d/ssh", isRaw = true ):
      break createSSHServer_application

    let sure: string = "Do you really want to install OpenSSH Server"
    if not askUser( sure, defaultChoice = false ):
      break createSSHServer_application

    freshInstallation = true
    discard installPackage( "openssh-server" )

  block createSSHServer_config:
    if not fileExists(r"/etc/ssh/sshd_config"):
      break createSSHServer_config

    # check port
    let sshPort = execCommand("""cat /etc/ssh/sshd_config | grep Port | cut -d " " -f 2""", user = USER, wantResult = true )

    if DEBUG:
      echo "Found SSH-Configuration for Port: " & sshPort

    if sshPort == "50505":
      break createSSHServer_config

    # if fresh overwrite
    if not freshInstallation:
      if not askUser( "Set SSH-Port to 50505", defaultChoice = false ):
        break createSSHServer_config

    discard execCommand( """sed -i "s/Port 22$/Port 50505/" /etc/ssh/sshd_config""", user = "root" )
    ## TODO need to restart ssh server... is called ssh, sshd, openssh?!?!?
    ## TODO need to check this first!!!
    if DEBUG:
      echo "Restart your SSH Daemon"

  block createSSHServer_cert:
    if fileExists( HOME & "/.ssh/id_rsa.pub" ):
      break createSSHServer_cert

    if not askUser( "You have no SSH-Key create any? (Type=RSA)", defaultChoice = false ):
      break createSSHServer_cert

    var possiblePassword: string = readPasswordFromStdin("Possibly a password: ")
    discard execCommand( "ssh-keygen -t rsa -f " & HOME & "/.ssh/id_rsa.pub -P '" & possiblePassword & "'", user = USER )
    if fileExists(HOME & "/.ssh/id_rsa.pub"):
      discard execCommand( "cat " & HOME & "/.ssh/id_rsa.pub |  xclip -selection clipboard", user = USER )
      if not SILENT:
        echo "Public RSA Key copied to your clipboard, add it to your Git Server!"

proc uninstall*( vars: DotfileModuleAttributes ): bool =
  include "../libraries/buildEnvironment.nim"
  echo "Goin to remove M20SSH Module"

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
