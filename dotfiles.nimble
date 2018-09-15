# Package

version     = "1.5"
author      = "LimeBlack"
description = "Installer for my Dotfiles"
license     = "MIT"
srcDir      = "src"
bin         = @["installer"]
#backend     = "c"
#binDir      = "src"
#installDirs = @["modules", "dotfiles"]
#skipDirs    = @["doc", "bin"]
#installFiles = @["installer"]

# Deps

requires "nim >= 0.18.0"

# Tasks

before install:
  echo "Installer and Modules should be compiled"
  exec "cd src/ && nim c -r buildModules"
  exec "cd src/ && nim c installer"

task install, "Running Installer":
  echo "installer should be run"
  exec "cd src/ && sudo ./installer"

after install:
  echo "Cleanup after work"
  exec "./bin/cleanup.sh"
