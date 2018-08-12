#[
  M01 Init - Dotfiles Module with runlevel 01

  Module to install basic Packages for Debian-Based Systems

  v0.4  - 17.03.2018 - 16:00
        - added PKG_MNG, DIST to environment
        - added blacklist
        - added centos support
        - added passing of packageManager and distribution

  v0.3  - 25.05.2017 - 15:00
        - cleaned imports

  v0.2  - 14.05.2017 - 03:20
        - fully working version

  v0.1  - 07.05.2017 - 20:23
        - just a stab

  Author: LimeBlack ~ David Crimi
]#

from tables   import `[]`, Table, toTable, keys

from "../libraries/arnold/arnold"       import installPackages, execCommand
from "../libraries/inception/inception" import CantInstallPackage
from "../libraries/dotfileTypes"        import DotfileModuleAttributes


let list_admin: seq[ string ] = @[
  # tools
  "aptitude",
  "gparted",
  "htop",
  "xclip",
  # various
  "python-software-properties",
  "build-essential",
  "automake",
  "pwgen"
]

# enviroments
let list_ide: seq[ string ] = @[
  "emacs", ## TODO replace with remacs TODO add spacemacs config
  "vim",
  "tmux",
]

# network packages
let list_networking: seq[ string ] = @[
  "nmap",
  "git",
  "curl",
  "wget",
  "links2",
  "slurm",
]

var list_android: seq[ string ] = @[
  "android-tools-adb",
  "android-tools-adbd",
  "android-tools-fastboot",
]
let DEBUG = false ## TODO use asyncLogger


proc install*( vars: DotfileModuleAttributes ): bool =

  include "../buildEnvironment.nim"
  var updateCommand = "update"
  var blacklist: seq[ string ] = @[]

  ## enable universe repo for ubuntu
  if DIST == "Ubuntu":
    discard execCommand( "add-apt-repository universe" )

  if DIST == "CentOS":
    discard execCommand( """echo "should add epel here"""" )
    blacklist.add("python-software-properties")
    blacklist.add("android-tools-adb")
    blacklist.add("android-tools-adbd")
    blacklist.add("android-tools-fastboot")
    blacklist.add("slurm")
    list_android.add("android-tools")

  ## update repositories
  if PKG_MNG == "yum":
    updateCommand &= " -q --assumeno"
    blacklist.add("aptitude")

  ## UPDATE
  discard execCommand( PKG_MNG & ' ' & updateCommand )

  let packages = {
    "ide":     list_ide
    "admin":   list_admin,
    "network": list_networking,
    "android": list_android
  }.toTable

  for package_group in packages.keys:

    echo "--------------------------------------------------"
    echo "# Going to install " & package_group & " Packages."
    echo "--------------------------------------------------"

    try:
      discard installPackages( packages[package_group], packageManager = PKG_MNG, distribution = DIST, blacklist = blacklist )
    except CantInstallPackage:
      # TODO cant fetch error here! - need to be done inside of installPackages
      echo getCurrentExceptionMsg()


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

