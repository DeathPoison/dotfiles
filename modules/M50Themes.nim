#[
  Themes - Dotfiles Module

  Module to install GTK Themes

  v0.1  - 13.05.2017 - 15:00
        - added a simple base Module
]#

## import dotfiles helper
from "../libraries/dotfile" import DotfileModuleAttributes

proc install*( vars: DotfileModuleAttributes ): bool =

  # include vars like: HOME, USER, ...
  include "../buildEnvironment.nim"

  echo "--------------------------------------------------"
  echo "# Going to install a GTK Theme."
  echo "--------------------------------------------------"

  # add choice for few themes:
  #  - arc-dark
  #  - delorean-dark

  echo "implement themes, only for ubuntu and debian"

  #[
    if DIST in [ 'Ubuntu', 'Debian' ]:
      packages = [
        'gnome-tweak-tool'
        'malys-uniwhite',
        'delorean-dark'
      ]

      if raw_input( 'Install Themes? [Y/n]:' ) in [ 'y', 'Y' ]:
        if not invoke( 'ls /usr/share/themes/delorean-dark 2>/dev/null' ):
          invoke( 'add-apt-repository ppa:noobslab/themes' )
          invoke( 'add-apt-repository ppa:noobslab/icons' )
          invoke( 'apt-get update' )
          installPackages( packages )
          print('change your theme ;)')
        #invoke( 'su ' + username + ' -c gnome-tweak-tool 2>/dev/null' )
        #print('FOOLED, just changed root appearance ;)')
  ]# 

when isMainModule:
  
  include "../testEnvironment.nim"
  
  discard install(DotfileModuleAttributes(
    user: USER,
    path: PATH,
    home: HOME,
    pwd:  PWD
  ))