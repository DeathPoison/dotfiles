#[
  M01 Init - Dotfiles Module with runlevel 01

  Module to install basic Packages for Debian-Based Systems

  v0.2  - 14.05.2017 - 03:20
        - fully working version

  v0.1  - 07.05.2017 - 20:23 
        - just a stab

  Author: LimeBlack ~ David Crimi
]#

## TODO clean this imports xD
from os       import fileExists, dirExists
from tables   import `[]`, Table, toTable, keys
from re       import re, contains, escapeRe

from "../libraries/arnold/arnold"       
import execCommand, checkCommand

from "../libraries/inception/inception" 
import CantInstallPackage

# cli loading spinners
#from "../libraries/spinner/spinner"     
#import Spinner, startSpinner, stopSpinner

## import dotfiles helper
from "../libraries/dotfile"
import askUser, installPackages, DotfileModuleAttributes

let DEBUG = true ## TODO use asyncLogger

proc install*( vars: DotfileModuleAttributes ): bool =

  block createInstallation:
    ## INSTALL PACKAGES
    ## TODO exclude lists to external files
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

    for package_group in packages.keys:

      ## TODO check before echo s.th.

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

