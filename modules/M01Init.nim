#[
  M01 Init - Dotfiles Module with runlevel 01

  Module to install basic Packages for Debian-Based Systems
  
  v0.3  - 25.05.2017 - 15:00
        - cleaned imports

  v0.2  - 14.05.2017 - 03:20
        - fully working version

  v0.1  - 07.05.2017 - 20:23 
        - just a stab

  Author: LimeBlack ~ David Crimi
]#

from tables   import `[]`, Table, toTable, keys

from "../libraries/arnold/arnold"       import installPackages
from "../libraries/inception/inception" import CantInstallPackage
from "../libraries/dotfileTypes"        import DotfileModuleAttributes


let list_admin: seq[ string ] = @[ 
  # tools
  "aptitude",
  "gparted",
  "htop",
  "xclip",
  # enviroments
  "emacs", ## TODO replace with remacs
  "vim",
  "tmux",
  # various
  "python-software-properties",
]

# network packages
let list_networking: seq[ string ] = @[
  "nmap",
  "git",
  "curl",
  "links2",
  "slurm",
]

let list_android: seq[ string ] = @[
  "android-tools-adb",
  "android-tools-adbd",
  "android-tools-fastboot",
]

var packages = { 
  "admin":   list_admin,
  "network": list_networking,
  "android": list_android
}.toTable
let DEBUG = true ## TODO use asyncLogger


proc install*( vars: DotfileModuleAttributes ): bool =

  for package_group in packages.keys:

    echo "--------------------------------------------------"
    echo "# Going to install " & package_group & " Packages."
    echo "--------------------------------------------------"

    try:
      discard installPackages( packages[package_group] )
    except CantInstallPackage:
      # TODO prevent to stop here!
      echo getCurrentExceptionMsg()


when isMainModule:
  
  include "../testEnvironment.nim"

  discard install(DotfileModuleAttributes(
    user: USER,
    path: PATH,
    home: HOME,
    pwd:  PWD
  ))

