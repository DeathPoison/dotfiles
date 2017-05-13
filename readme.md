```
# CHANGELOG
#
# Setup Script for Debian-Based Systems v0.9a
# For Ubuntu Gnome 15.04.1 - should work for most...
#
# Author: LimeBlack ~ David Crimi - deathpoison.dc@gmail.com
# StartDate: 31.08.2014
#
#             v0.9b  - 13.05.2017 - 04:05
#                    - modules working!! 
#                    - -> excluded them into external application, 
#                    -    which needs to be executed BEFORE the installer will be compiled
#                    - i need to finish the module mpad, and write some more
#                    - i should also should add a sort of the modules and add the syntax: 00_name.nim 
#                    - -> (use the counter like runlevels)
#
#             v0.9a  - 23.04.2017 - 29:40
#                    - added user env to arnold commands
#                    - added some users to commands
#                    - added progress summary
#                    - readded username input
#                    - fixed home and pwd detection
#                    - removed use of gksudo <- input is not allowed!
#
#             v0.9   - 16.04.2017 - 00:25
#                    - added arguments:
#                      - "-s", "--silent"  <- for silent mode - less output
#                      - "-d", "--debug"   <- for debug  mode - more output
#                      - "-f", "--force"   <- for force  mode - overwrite all files
#                      - "-h", "--help"     this help text
#                      - "-v", "--version"  show version
#
#                    - installation of packages is not possible without adding sudo to arnold
#
#                    - @ARNOLD - TODO need to add sudo without run the whole script as sudo...
#                    - @ARNOLD - added async execution to arnold
#
#                    - @SPINNER - added progressLabel and progressText to spinners
#
#             v0.8   - 16.04.2017 - 12:12
#                    - fixed async command execution
#                    - need to fix ownership of generated files... -> use given user for commands
#
#             v0.7   - 10.04.2017 - 00:15          
#                    - rewrote script in NIM
#                    - added nice loading spinners
#       
#                    - need to add async processing to arnold
#                  
#                    - splited in some modules ( blocks )
#                    - need to make all this more modular, but should not be a big deal!
# 
#             v0.6   - 09.11.2016 - 11:00
#                    - added mnt alias
#                    - fixed git add alias
#                    - removed master branch from gp
#
#             v0.5   - 19.06.2016 - 22:22
#                    - added nim install
#
#             v0.4   - 14.08.2015 - 00:30
#                    - added checks for os and distribution, also for remote servers
#                    - added few more modules ;) - make it usefull!
#
#             v0.3   - 26.07.2015 - 23:00
#                    - rewrote to python script... much more attractive!
#
#             v0.2   - 26.07.2015 - 21:00
#                    - added configs and root access
#
#             v0.1   - 31.08.2014 - 14:00
#                    - added simple bash script to install not-installed packages
# 
```


