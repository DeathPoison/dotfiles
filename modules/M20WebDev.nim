#[
  WebDev - Dotfiles Module

  Module to install Web - Developer Tools

  v0.1  - 13.05.2017 - 16:50
        - added this Module
  
  Author: LimeBlack ~ David Crimi
]#

## import dotfiles helper
from "../libraries/dotfile" import DotfileModuleAttributes, askUser

proc install*( vars: DotfileModuleAttributes ): bool =

  # include vars like: HOME, USER, ...
  include "../buildEnvironment.nim"

  echo "--------------------------------------------------"
  echo "# Going to install Web - Developer Tools."
  echo "--------------------------------------------------"

  ## TODO install nodejs https://askubuntu.com/questions/426750/how-can-i-update-my-nodejs-to-the-latest-version
  ## TODO install yarn
  ## TODO added test db with pass l4r4v3l https://www.digitalocean.com/community/tutorials/how-to-create-a-new-user-and-grant-permissions-in-mysql

  ## TODO check if one of them is already installed
  if true:
    return false

  echo "--------------------------------------------------"
  echo "# Going to install an Web Server."
  echo "--------------------------------------------------"
  if not askUser( "Want a Web Server?" ):
    return false

  block createWebDevTools_apache2:
    if not askUser( "want apache2 ?!?!!", defaultChoice = false ):
      echo "right choice"
      break createWebDevTools_apache2
    else:
      echo "from now i guarantee for nothing..."
      echo "and it needs to be implemented!"

    #[
      if raw_input( 'Install Web-Dev Tools? [Y/n]:' ) in [ 'y', 'Y' ]:
        packages = [
            'mysql-server',
            'apache2',
            'php5',
            'phpmyadmin'
        ]

        installPackages( packages )

        if invoke( 'a2enmod rewrite' ):
            invoke( 'service apache2 restart' )

        if checkRemoteHost( 'http://192.168.0.150/' ):
            if not invoke( 'ls /var/www/html/.git 2>/dev/null' ):
                if raw_input( 'Clone HTML Repo and DELETE your HTML folder? [Y/n]:' ) in [ 'y', 'Y' ]:
                    invoke( 'cd /var/www/;rm -rf html;git clone ssh://git@192.168.0.150:50505/html.git' )
            else:
                invoke( 'cd /var/www/html;git pull' )
    ]#

  block createWebDevTools_nginx:
    echo "needs to be implemented"


when isMainModule:
  
  include "../testEnvironment.nim"
  
  discard install(DotfileModuleAttributes(
    user: USER,
    path: PATH,
    home: HOME,
    pwd:  PWD
  ))