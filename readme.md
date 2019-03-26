### Dotfiles [deprecated]

Just a NIM Script to install needed tools on various Linux Distributions, mostly Debian, Ubuntu or CentOS

Too run this:
- checkout nim repo ~ private****
- create symlink to libraries directory
- call runInstallation.sh

Usage of Dotfiles Installer:

Argument:          Description:
"-s", "--silent"   silent mode - less output
"-d", "--debug"    debug  mode - more output
"-f", "--force"    force  mode - overwrite all files
"-h", "--help"     this help text
"-v", "--version"  show version

```
# CHANGELOG
#
# Setup Script for Debian-Based Systems v0.9a
# For Ubuntu Gnome 15.04.1 - should work for most...
#
# Author: LimeBlack ~ David Crimi - deathpoison.dc@gmail.com
# StartDate: 31.08.2014
#
# v1.5   - 15.09.2018 - 15:42
#        - added some structure ~ bin directory;
#        - cleaned bashrc
#        - added zsh
#
# v1.4   - 15.08.2018 - 22:22
#        - added i3 with rofi, feh, compton
#
# v1.3   - 17.03.2018 - 16:20
#        - added CentOS support
#        - added dynamic package managers: yum, apt
#
# v1.2   - 30.05.2017 - 20:00
#        - added some documentatioon
#
# v1.1   - 25.05.2017 - 20:00
#        - added dependencie check for modules, with little error solver
#        - excluded dotfile types
#        - moved installpackage to arnold
#        - improved package checking ~ arnold
#        - added fixes for ubuntu universe repo
#        - errorsolver is able to install node, npm and yarn... wrong place? -> i want to add modules as dependencie type
#        - improved gitignore file
#        - added DIST to module vars
#
# v1.0   - 14.05.2017 - 03:30
#        - added runInstallation.sh
#        - -> builds and run through the whole installation process
#
#        - added bash script to install nim and nimble: installNim.sh
#
#        - added a basic module template
#        - added buildEnvironment/tstEnvironment to test Modules
#
#        - Created working and ready Modules:
#        - M01Init        -> installs Packages
#        - M05Dotfiles    -> copy all dotfiles
#        - M20Git         -> configure github
#        - M20OpenSSH     -> not tested
#        - M20WebDev      -> not tested
#        - M50Terminology -> not tested
#        - M50Themes      -> should install gtk3 themes ! unfinished, unimportant
#        - M50Vim         -> installs VIM-Plugins ( vundle and config, should already there! )
#        - M50Wine        -> installs wine ! not tested, should work
#        - M50mPad        -> installs mPad
#
#        - this should be a fully working version ( except few modules )
#
# v0.9c  - 13.05.2017 - 17:30
#        - excluded all blocks to modules
#
# v0.9b  - 13.05.2017 - 04:05
#        - modules working!! 
#        - -> excluded them into external application, 
#        -    which needs to be executed BEFORE the installer will be compiled
#        - i need to finish the module mpad, and write some more
#        - i should also should add a sort of the modules and add the syntax: 00_name.nim 
#        - -> (use the counter like runlevels)
#
# v0.9a  - 23.04.2017 - 29:40
#        - added user env to arnold commands
#        - added some users to commands
#        - added progress summary
#        - readded username input
#        - fixed home and pwd detection
#        - removed use of gksudo <- input is not allowed!
#
# v0.9   - 16.04.2017 - 00:25
#        - added arguments:
#          - "-s", "--silent"  <- for silent mode - less output
#          - "-d", "--debug"   <- for debug  mode - more output
#          - "-f", "--force"   <- for force  mode - overwrite all files
#          - "-h", "--help"     this help text
#          - "-v", "--version"  show version
#
#        - installation of packages is not possible without adding sudo to arnold
#
#        - @ARNOLD - TODO need to add sudo without run the whole script as sudo...
#        - @ARNOLD - added async execution to arnold
#
#        - @SPINNER - added progressLabel and progressText to spinners
#
# v0.8   - 16.04.2017 - 12:12
#        - fixed async command execution
#        - need to fix ownership of generated files... -> use given user for commands
#
# v0.7   - 10.04.2017 - 00:15          
#        - rewrote script in NIM
#        - added nice loading spinners
#       
#        - need to add async processing to arnold
#                  
#        - splited in some modules ( blocks )
#        - need to make all this more modular, but should not be a big deal!
# 
# v0.6   - 09.11.2016 - 11:00
#        - added mnt alias
#        - fixed git add alias
#        - removed master branch from gp
#
# v0.5   - 19.06.2016 - 22:22
#        - added nim install
#
# v0.4   - 14.08.2015 - 00:30
#        - added checks for os and distribution, also for remote servers
#        - added few more modules ;) - make it usefull!
#
# v0.3   - 26.07.2015 - 23:00
#        - rewrote to python script... much more attractive!
#
# v0.2   - 26.07.2015 - 21:00
#        - added configs and root access
#
# v0.1   - 31.08.2014 - 14:00
#        - added simple bash script to install not-installed packages
# 
```


