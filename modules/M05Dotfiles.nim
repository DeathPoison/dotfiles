#[
  Dotfiles - Dotfiles Module

  Module to install Dotfiles for Debian Based Systems
  This file really does ;)
  
  v0.2  - 25.05.2017 - 14:30
        - added dependencies

  v0.1  - 13.05.2017 - 15:13 
        - working

  Author: LimeBlack ~ David Crimi
]#

from os       import fileExists, dirExists
from tables   import `[]`, Table

## import dotfiles helper
from "../libraries/dotfile"
import askUser, copy

from "../libraries/arnold/arnold"       
import execCommand, checkCommand, validCommand

from "../libraries/dotfile" import checkDependencies
from "../libraries/dotfileTypes"
import DotfileObj, DotfileModuleAttributes, Dependencies, Dependencie, command, directory


## TODO use asyncLogger
let DEBUG = true

proc install*( vars: DotfileModuleAttributes ): bool =

  # include vars like: HOME, USER, ...
  include "../buildEnvironment.nim"

  ## define your dependencies
  let deps: Dependencies = Dependencies(
    module: "dotfiles",
    dependencies: @[
      Dependencie( 
        name: "home/git", description: "Home git Directory, which is used for my git server", 
        kind: directory,  path: HOME & "/git" 
      ),
      Dependencie( 
        name: "home/git/EXTERNAL", description: "Home git/EXTERNAL Directory, which is used for github", 
        kind: directory,  path: HOME & "/git/EXTERNAL" 
      ),
    ]
  )
  if not checkDependencies( deps, vars ):
    return false


  echo "--------------------------------------------------"
  echo "# Going to install Dotfiles Packages."
  echo "--------------------------------------------------"

  # only copy files if ~/.bashrc will be used
  if not fileExists( HOME & r"/.bashrc" ):
    echo "No " & HOME & r"/.bashrc" & "found... skip installation of Dotfiles..." 
    quit()

  # install fonts 
  if not dirExists( HOME & r"/git/EXTERNAL/fonts" ):
    discard execCommand( r"git clone https://github.com/powerline/fonts.git " & HOME & r"/git/EXTERNAL/fonts 2>/dev/null", user = USER )
    discard execCommand( "cd " & HOME & r"/git/EXTERNAL/fonts && fc-cache -f -v 1>/dev/null", user = USER )

  block createBashAliasConnection:

    if 1 > validCommand( r"cat  " & HOME & r"/.bashrc | grep '.bash_aliases'", isRaw = true ):
      break createBashAliasConnection

    var aliasConnection: string    = "\n\n" & r"if [ -f " & HOME & "/.bash_aliases ]; then"
    aliasConnection = aliasConnection & "\n" & "    . " & HOME & "/.bash_aliases"
    aliasConnection = aliasConnection & "\n" & "fi" & "\n"

    if DEBUG:
      echo aliasConnection

    let file = open( filename = HOME & r"/.bashrc", FileMode(4))
    file.write(aliasConnection)
    file.close()

  block createDotfiles:
    let dotfiles: seq[ DotfileObj ] = @[ 
      DotfileObj(
        name: "bash_alias",
        target: PWD & r"/dotfiles/bash_aliases",
        destination: "/.bash_aliases", # user's home path is missing!
        isDir: false,
        overwrite: true
      ),
      DotfileObj(
        name: "shell_prompt",
        isDir: false,
        target: PWD & r"/dotfiles/shell_prompt.sh",
        destination: "/.shell_prompt", # user's home path is missing!
        overwrite: true
      ),
      DotfileObj(
        name: "tmux_prompt",
        isDir: false,
        target: PWD & r"/dotfiles/tmux_prompt.sh",
        destination: "/.tmux_prompt", # user's home path is missing!
        overwrite: true
      ),
      DotfileObj(
        name: "tmux",
        isDir: false,
        target: PWD & r"/dotfiles/tmux.conf",
        destination: "/.tmux.conf", # user's home path is missing!
      ),
      DotfileObj(
        name: "vim",
        isDir: true,
        target: PWD & r"/dotfiles/vim",
        destination: "/.vim", # user's home path is missing!
      ),
      DotfileObj(
        name: "vimrc",
        isDir: false,
        target: PWD & r"/dotfiles/vimrc",
        destination: "/.vimrc", # user's home path is missing!
      )
    ]    
    for dotfile in dotfiles:
      var overwriteFile = dotfile.overwrite
      if FORCE:
        overwriteFile = true
      discard copy( dotfile.target, HOME & dotfile.destination, user = USER, isDir = dotfile.isDir, overwrite = overwriteFile )

      # some packages need Clayton Handling      
      case dotfile.name
      of "vim":
        if not dirExists( HOME & r"/.vim/bundle/Vundle.vim" ):
          if DEBUG:
            echo "Clone Vundle to: " & HOME & r"/.vim/bundle/Vundle.vim"
          discard execCommand( r"git clone https://github.com/gmarik/Vundle.vim.git " & HOME & "/.vim/bundle/Vundle.vim 2>/dev/null", user = USER )
          #discard setOwner( USER, target = HOME & "/.vim", isDir = true )
        else:
          if DEBUG:
            echo "Vundle already exists"
      else: discard


when isMainModule:

  include "../testEnvironment.nim"

  discard install(DotfileModuleAttributes(
    user: USER,
    path: PATH,
    home: HOME,
    pwd:  PWD
  ))

