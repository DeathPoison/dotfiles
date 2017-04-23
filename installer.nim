#[

  Dotfiles

  Script to create my linux enviroment

]#

from os       import fileExists, dirExists, sleep, commandLineParams, getCurrentDir
from net      import newSocket, connect, Port, close
from rdstdin  import readPasswordFromStdin
from posix    import getegid, onSignal, SIGINT, SIGTERM
from tables   import toTable, keys, `[]`
from re       import re, contains, escapeRe

from threadpool import spawn, sync

# custom error types
from libraries.inception.inception 
import WrongOS, CantInstallPackage

# command executor
from libraries.arnold.arnold       
import execCommand, setOwner, validCommand, checkCommand, checkFile

from libraries.arnold.arnold       
import startCommand, spawnCommand, isActive

from libraries.inception.inception 
import CmdDoesNotExists, CmdRaisesError

# cli loading spinners
from libraries.spinner.spinner     
import Spinner, startSpinner, stopSpinner


type
  # Container for files being used by this app
  DotfileObj = object           ## With the creation of a referenze
    name: string
    isDir: bool                 ## this object transforms into a
    overwrite: bool
    target: string              ## immutable procedure, dont need it now!
    destination: string

## TODO read from .env file ~ https://github.com/euantorano/dotenv.nim 
# - hint him to add namespaces           e.g.: "namespace.var = value"
# - hint him to add array  (seq[string]) e.g.: "var[] = value"
# - hint him to add hashes (table)       e.g.: "var[grande] = value"

## TODO replace concat of long text with s.th. usefull xD, iam lazy! 
## -> format or % or similar

var DEBUG: bool = false
let HELP: string = """
  
  Dotfile Installer

  Argument:          Description:
  "-s", "--silent"   silent mode - less output
  "-d", "--debug"    debug  mode - more output
  "-f", "--force"    force  mode - overwrite all files   
  "-h", "--help"     this help text
  "-v", "--version"  show version
"""
let VERSION: string = "v0.9 - 16.04.2017 - 00:25"
let AUTHOR:  string = "LimeBlack ~ David Crimi"
var PATH:    string = os.getEnv("PATH") ## TODO probably i need to use arnold to get the corrent enviroment
var HOME:    string = "" # /home/poisonweed
var USER:    string = "" # your used user -> install packages and enviroment for him!

var HISTORY: seq[ string ] = @[] ## TODO xD replace HISTORY with cleaner summary and add async logger
var PWD:     string  # working dir 
var ARCH:    string  # used arch eg: x86_64
var DIST:    string  # used dist eg: Ubuntu or Debian
var SILENT:  bool    # ask questions?
var FORCE:   bool    # should overwrite all?
# TODO var PKG_MNG: string  # used package manager: only apt and apt-get for now!

# ask user if he really want to do: whatToDo
proc askUser( whatToDo: string, defaultChoice: bool = true ): bool = 
  var defaultPossibilities = "[Y/n]"
  if not defaultChoice:
    defaultPossibilities = "[y/N]"

  stdout.write whatToDo & " " & defaultPossibilities & ": "
  var userChoice = stdin.readline()
  
  # set empty to true if wanted
  if defaultChoice and userChoice == "":
    userChoice = "y"

  case userChoice
  of 
    "Y", 
    "yes", 
    "y":
    result = true
  else: result = false

  HISTORY.add( "You answered with " & userChoice & " to the following question: " & whatToDo )

#[ If egid > 500 i am not a root user! ]#
proc checkRoot(): bool = getegid() < 500

#[ Copy Method - selfExplaining! ]#
proc copy( 
  inputfile, outputfile: string, 
  user: string = "", 
  isDir: bool = false,
  overwrite: bool = false 
): bool =
  if DEBUG:
    echo "Try copy File: " & inputfile & " to " & outputfile

  if not overwrite:
    if checkFile(outputfile, isDir = isDir ):
      let problem = "File " & outputfile & " already exists, should be overwritten?"
      if not askUser( problem, false ):
        return false
      
      echo "should overwrite"

  var copyCommand: string = "cp "
  if isDir:
    copyCommand = copyCommand & "-R "

  var command: string = copyCommand & inputfile & " " & outputfile

  if DEBUG:
    echo command

  discard execCommand( command, user = user )

  HISTORY.add( "Copied: " & inputfile & " to: " & outputfile )

  return true

proc installPackage( package: string ): bool =
  ## HINT install must be quiet!
  ## TODO add error handling here
  result = true
  if not checkCommand( package ):
    discard execCommand( "apt install -y " & package, user = "root" )
    HISTORY.add( "Installed package: " & package )  
    result = checkCommand( package )

proc installPackages( packages: seq[ string ] ): bool =
  ## TODO remove this misuse of exceptions here!!!
  try:
    for package in packages:
      if not installPackage( package ):
        raise newException( CantInstallPackage, "Cant install package: " & package );
  except CantInstallPackage:
    echo getCurrentExceptionMsg()
    return false
  return true

# get Processor Arch
proc getArch(): string =
  try:
    result = execCommand( "lscpu | grep Archi | cut -d \":\" -f 2", user = "root", wantResult = true )
  except CmdDoesNotExists:
    raise newException(WrongOS, "No suitable OS found...")

# get current distribution
proc getDistribution(): string =
  try:
    result = execCommand( "lsb_release -a 2>/dev/null | grep Distributor | cut -f 2", user = "root", wantResult = true )
  except CmdDoesNotExists:
    if DEBUG:
      echo "Command does not exists: " & getCurrentExceptionMsg()  
    result = execCommand( "uname", user = "root", wantResult = true )

# check if server is alive
proc checkServer( host: string, port: Port = Port(80) ): bool =
  var socket = newSocket()
  try:
    socket.connect( host, port, 500 )
    socket.close()
    result = true
  except Exception:
    discard socket
    result = false

proc stopApplication( 
  message: string = "\n\nGo'in to stop this Application",
  exitcode: int = 0
) = 
  echo message
  sync()
  HISTORY.add( "Closed Application" )
  quit(exitcode)

# CTRL + C
onSignal( SIGINT, SIGTERM ):
  
  var msg: string = ""
  if not (SILENT or FORCE):
    msg = "\n\nYou Pressed CTRL + C"

  HISTORY.add( "You interrupted the application with CTRL + C" )
  stopApplication( message = msg, exitcode = 130 )


## START ################################
when isMainModule:

  block checkEnviroment:
    # check arguments ~ called params in NIM-Lang
    when declared(commandLineParams):
      for param in commandLineParams():
        case param
        of "-s", "--silent":
          SILENT = true
        of "-f", "--force":
          FORCE = true
        of "-d", "--debug":
          DEBUG = true
        of "-h", "--help":
          echo HELP
          echo "  Version: ", VERSION
          echo "  Author:  ",  AUTHOR
          stopApplication( message = ""   )
        of "-v", "--version":
          echo "Version: ", VERSION
          echo "Author:  ",  AUTHOR
          stopApplication( message = ""   )
        else:
          continue

    if not checkServer( host = "heise.de" ):
      echo "you need an internet connection!"
      stopApplication( exitCode = 1 )
    
    try:
      ARCH = getArch()
    except WrongOS:
      echo "ERROR"
      echo getCurrentExceptionMsg()
      stopApplication( exitCode = 1 )

    # TODO add multiple package-managers
    if not checkCommand("apt") or not checkCommand("apt-get"):
      stopApplication( exitCode = 1 )

    # TODO add error handling
    DIST = getDistribution()
    PWD  = os.getCurrentDir() # execCommand( "pwd", wantResult = true )

    stdout.write( "\nPlease enter your Username: [poisonweed]" )
    USER = stdin.readline()

    if USER == "":
      USER = "poisonweed"

    HOME = "/home/" & USER
    if USER == "root":
      HOME = "/root"

  block checkSetup:  
    # print fetched infos
    if SILENT or FORCE:
      break checkSetup

    var enviroment: string = "" & 
      "---------------------------" & "\n" &
      "Your entered  User: " & USER & "\n" &
      "Your detected Arch: " & ARCH & "\n" &
      "Your detected Dist: " & DIST & "\n" &
      "Your detected Home: " & HOME & "\n" &
      "Your detected PWD:  " & PWD  & "\n" &
      "---------------------------"

    echo enviroment

    if not checkRoot():
      echo "try again as root user!"
      quit(1)

    if not askUser( "Want to proceed? Check the detected Enviroment above!", defaultChoice = true ):
      quit(1)

  block createInstallation:
    ## INSTALL PACKAGES
    ## TODO exclude lists to external files
    let list_admin: seq[ string ] = @[ 
      # tools
      "aptitude",
      "gparted",
      "nmap",
      "htop",
      "xclip",
      # enviroments
      "emacs",
      "vim",
      "tmux",
      # network
      "git",
      "curl",
      "links2",
      "slurm",
      # various
      "python-software-properties",
    ]
    
    let list_android: seq[ string ] = @[
      "android-tools-adb",
      "android-tools-adbd",
      "android-tools-fastboot",
    ]
    
    var packages = { 
      "admin":   list_admin,
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

  ## TODO add "~/bin" to PATH
  block createUserConfigurations:
    echo "--------------------------------------------------"
    echo "# Going to install Dotfiles Packages."
    echo "--------------------------------------------------"

    # only copy files if ~/.bashrc will be used
    if not fileExists( HOME & r"/.bashrc" ):
      echo "No " & HOME & r"/.bashrc" & "found... skip installation of Dotfiles..." 
      quit()

    block createGitDir:
      # create $HOME/git 
      if not dirExists( HOME & r"/git" ):
        discard execCommand( "mkdir " & HOME & r"/git 2>/dev/null", user = USER ) 
      
      # create $HOME/git/EXTERNAL
      if not dirExists( HOME & r"/git/EXTERNAL" ):
        discard execCommand( "mkdir " & HOME & r"/git/EXTERNAL 2>/dev/null", user = USER ) 

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

    # check if plugins already installed?, not nesseccary...
    ## TODO make sure this will be executed as USER
    ## make sure vim is installed!
    ## probably cancel this process after a timeout...or make sure the config has no errors!
    block createVimPlugins:
      let sp = Spinner( 
        spinner: "clock", 
        progressLabel: "Installing:",
        progressText: "VIM-Plugins: ctrlp, nerdtree, some more...",
        doneText: "DONE!", 
        abortText: "Stopped", 
        defaultDelay: 75, 
        stream: stdout 
      )

      ## TODO set owner of ~/.vim dir
      if checkCommand( "vim", user = USER ):
        stdout.write "Installing VIM-Plugins: "

        startCommand( "vim +PluginInstall +qall", user = USER )
        ## TODO move spawn to startSpinner proc! - dont want this spawn sync fu in my application
        spinner.spawnSpinner sp

        while isActive():       # while command is running: wait!  ~ could do sync here, but... this way iam able to include dirty hacks like set position after spinner and display some text there... iam not going to do this!!!
          sleep( 200 )
        
        spinner.stopSpinner()   # stop spinnerThread
        sync()                  # make sure threads are finished @spinner, arnold

  block createTerminologyPPAs:
    if checkCommand( "terminology" ): break createTerminologyPPAs        

    echo "--------------------------------------------------"
    echo "# Going to add Terminology Repository."
    echo "--------------------------------------------------"
    let sure: string = "Do you really want to add a PPA and install Terminology?"

    if not askUser( sure, defaultChoice = false ): 
      break createTerminologyPPAs

    discard execCommand( "add-apt-repository -y ppa:enlightenment-git/ppa", user = "root" )
    discard execCommand( "apt update", user = "root" )
    if installPackage( "terminology" ):
      if not SILENT:
        echo "successfully installed Terminology"

  block createSSHServer:

    echo "--------------------------------------------------"
    echo "# Going to install an OpenSSH Server."
    echo "--------------------------------------------------"
    var freshInstallation: bool = false
    
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
      let sshPort = execCommand("cat /etc/ssh/sshd_config | grep Port | cut -d ' ' -f 2", user = USER, wantResult = true )
      
      if DEBUG:
        echo "Found SSH-Configuration for Port: " & sshPort

      if sshPort == "50505":
        break createSSHServer_config

      # if fresh overwrite
      if not freshInstallation:
        if not askUser( "Set SSH-Port to 50505", defaultChoice = true ):
          break createSSHServer_config

      discard execCommand( "sed -i 's/Port 22$/Port 50505/' /etc/ssh/sshd_config", user = "root" )
      ## TODO need to restart ssh server... is called ssh, sshd, openssh?!?!?
      ## TODO need to check this first!!!
      if DEBUG:
        echo "Restart your SSH Daemon"

    block createSSHServer_cert:
      if fileExists( HOME & "/.ssh/id_rsa.pub" ):
        break createSSHServer_cert

      if not askUser( "You have no SSH-Key create any? (Type=RSA)", defaultChoice = false ):
        break createSSHServer_cert

      if not checkCommand( "xclip", user = USER ):
        ## TODO add exit procedure
        echo "How could this happen? XClip is not installed... rerun this script, install admin packages!"
        break createSSHServer_cert

      var possiblePassword: string = readPasswordFromStdin("Possibly a password: ")
      discard execCommand( "ssh-keygen -t rsa -f " & HOME & "/.ssh/id_rsa.pub -P '" & possiblePassword & "'", user = USER )
      if fileExists(HOME & "/.ssh/id_rsa.pub"):
        discard execCommand( "cat " & HOME & "/.ssh/id_rsa.pub |  xclip -selection clipboard", user = USER )
        if not SILENT:
          echo "Public RSA Key copied to your clipboard, add it to your Git Server!"

  block createWebDevTools:

    ## TODO install nodejs https://askubuntu.com/questions/426750/how-can-i-update-my-nodejs-to-the-latest-version
    ## TODO install yarn
    ## TODO added test db with pass l4r4v3l https://www.digitalocean.com/community/tutorials/how-to-create-a-new-user-and-grant-permissions-in-mysql

    ## TODO check if one of them is already installed
    if true:
      break createWebDevTools

    echo "--------------------------------------------------"
    echo "# Going to install an Web Server."
    echo "--------------------------------------------------"
    if not askUser( "Want a Web Server?" ):
      break createWebDevTools

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

  block createGitConfig:
    if checkCommand("git"):
      break createGitConfig

    let haveUsername: bool = checkCommand("git config --global user.name")
    let haveEmail:    bool = checkCommand("git config --global user.email")

    if haveEmail and haveUsername:
      break createGitConfig

    echo "--------------------------------------------------"
    echo "# Going to install Git."
    echo "--------------------------------------------------"
    if not askUser( "Want git?", defaultChoice = false ):
      break createGitConfig

    if not haveUsername:
      discard execCommand( "git config --global user.name " & USER, user = USER )

    if not haveEmail:
      stdout.write("Give my an email for your config: ")
      let email = stdin.readLine()
      discard execCommand( "git config --global user.email " & email, user = USER )

  block createNimDist:
    let haveNim:    bool = fileExists( HOME & r"/git/EXTERNAL/Nim/bin/nim" )
    let haveNimble: bool = fileExists( HOME & r"/git/EXTERNAL/nimble/nimble" )
    
    if haveNimble and haveNimble:
      break createNimDist

    echo "--------------------------------------------------"
    echo "# Going to install Nim, from Git not from official repos..."
    echo "--------------------------------------------------"

    # nim only work if you use my bash_alias file!
    
    block createNimDist_nim:
      if haveNim: break createNimDist_nim

      if not askUser( "Want Nim?" ):
        ## HINT without nim, nimble gets uninteressting!
        break createNimDist

      if dirExists( HOME & r"/git/EXTERNAL/Nim" ):
        discard execCommand( "cd " & HOME & r"/git/EXTERNAL/Nim && git pull", user = USER )
      else:
        # clone git and csources directory
        discard execCommand( r"git clone https://github.com/nim-lang/Nim.git " & HOME & r"/git/EXTERNAL/Nim", user = USER )
        discard execCommand( r"git clone --depth 1 https://github.com/nim-lang/csources " & HOME & r"/git/EXTERNAL/Nim/csources", user = USER )
      
      # build csources & nim & koch
      discard execCommand( "cd " & HOME & r"/git/EXTERNAL/Nim/csources/ && sh build.sh", user = USER )
      discard execCommand( "cd " & HOME & r"/git/EXTERNAL/Nim/ && bin/nim c koch", user = USER )
      discard execCommand( "cd " & HOME & r"/git/EXTERNAL/Nim/ && ./koch boot -d:release", user = USER )
    
    block createNimDist_nimble:
      if haveNimble: break createNimDist_nimble

      if not askUser( "Want Nimble?" ):
        break createNimDist_nimble

      #[
        Run command: source /root/.bash_aliases && cd /root/git/EXTERNAL/nimble/ && nim -d:release c -r src/nimble -y install
          Traceback (most recent call last)
          install.nim(645)         install
          install.nim(65)          execCommand
          Error: unhandled exception: 127 [CmdRaisesError]
        Probably because root is not able to execute nim? in this enviroment
        but looks like BASH_PROMT is loaded, why not should this dont work?
        -> because i running this script as sudo?!?!

        Cant install Nim as Sudo...
        -> SUDO is doing env variables reset by default.
      ]#

      if not dirExists( HOME & r"/git/EXTERNAL/nimble" ):
        discard execCommand( "git clone https://github.com/nim-lang/nimble.git " & HOME & r"/git/EXTERNAL/nimble", user = USER )
      try:
        discard execCommand( r"cd " & HOME & r"/git/EXTERNAL/nimble/ && PATH=$PATH:" & HOME & "/git/EXTERNAL/Nim/bin/nim nim -d:release c -r src/nimble -y install", user = USER )
      except CmdRaisesError:
        echo getCurrentExceptionMsg()

  block createMPad:
    if checkCommand( "mpad", user = USER ):
      break createMPad

    echo "--------------------------------------------------"
    echo "# Going to install an mpad."
    echo "--------------------------------------------------"

    echo "NOT READY YET!!!"

    if not askUser( "Want to install mpad?", defaultChoice = true ):
      break createMPad

    if not dirExists( HOME & r"/git/EXTERNAL/mpad" ):
      discard execCommand( r"git clone https://github.com/DeathPoison/mpad.git " & HOME & r"/git/EXTERNAL/mpad 2>/dev/null", user = USER )

    ## TODO make sure ~/bin dir exists and is in PATH
    if not PATH.contains( re escapeRe( HOME & r"/bin" ) ):
      if DEBUG:
        echo "add " & HOME & "/bin to $PATH"
      discard execCommand( "PATH=$PATH:" & HOME & r"/bin", user = USER )
    else:
      echo HOME & "/bin found in PATH"

    ## build mpad
    ## create symlink to ~/bin
    ## create desktop link

  block createThemeConfig:
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

  block createWine:
    ## TODO https://wiki.winehq.org/Ubuntu
    break createWine

  var successMessage: string = "" &
    "##################################################" & "\n" &
    "# Successfully installed, here comes the Summary:"  & "\n" &
    "#" & "\n" &
    "##################################################" & "\n"
  ## TODO add summary here!
  for event in HISTORY:
    successMessage = successMessage & event & "\n"
  successMessage = successMessage & "##################################################"
  echo successMessage
  quit()
