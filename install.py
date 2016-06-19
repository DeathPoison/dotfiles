#!/usr/bin/env python
#
# Ubuntu Setup Script v.1e
# For Ubuntu Gnome 15.04.1 - should work for most...
#
# Author:
#            D. Crimi - deathpoison.dc@gmail.com
# Date:
#            v0.1 - 31.08.2014 - 14:00
#                 - added simple bash script to install notinstalled packages
#            v0.2 - 26.07.2015 - 21:00
#                 - added configs and root access
#            v0.3 - 26.07.2015 - 23:00
#                 - rewrote to python script... much more attractive!
#            v0.4 - 14.08.2015 - 00:30
#                 - added checks for os and distribution, also for remote servers
#                 - added few more modules ;) - make it usefull!
#            v0.5 - 19.06.2016 - 22:22
#                 - added nim install

global DEBUG
DEBUG = True

from os import getegid
from urllib2 import urlopen
from shutil import copy2, copytree
from subprocess import PIPE, Popen

def copy( target, destination, user, overwrite = False ):
    writeFile = False
    if not invoke( 'ls ' + destination +' 2>/dev/null' ):
        writeFile = True

    if writeFile or overwrite:
        copy2( target, destination )
        invoke( 'chown '+user+':'+user+' '+destination )
        return True

    return False

def copyDir( target, destination, user ):
    if not invoke( 'ls ' + destination +' 2>/dev/null' ):
        copytree( target, destination )
        invoke( 'chown -R '+user+':'+user+' '+destination )
        return True
    return False


def invoke( command ):
    if DEBUG:
        print( 'run command: ' + command )
    return Popen( command, stdout=PIPE, shell=True ).stdout.read()

def checkRoot():
    if getegid() > 500:
        print 'Login as root!'
        shutdown()
    return True

def checkDistribution():
    if checkModule( 'uname' ):
        DISTRIBUTION = invoke( 'uname' ).strip()

    if checkModule( 'lsb_release' ):
        DISTRIBUTION = invoke( 'lsb_release -a 2>/dev/null | grep Distributor | cut -f 2' ).strip()

    return DISTRIBUTION

def checkOS():
    if checkModule( 'lscpu' ):
        return invoke( "lscpu | grep Archi | cut -d ':' -f 2" ).strip()
    return False

def checkGitDir():
    return invoke( 'pwd' ).strip()

def checkRemoteHost( ip ):
    try:
        connection = urlopen( ip, timeout=3 )
    except:
        return False
    if connection:
        # print connection.getcode()
        connection.close()
        return True
    return False

def checkModule( module ):
    blacklist = [ 'python-software-properties' ]    # dont check these packages
    check_alias = {                                 # package alias to check them!
        'mysql-server':           'mysql',
        'android-tools-adb':      'adb',
        'android-tools-adbd':     'adb',
        'android-tools-fastboot': 'fastboot',
    }

    if module in check_alias:                       # rename them
        module = check_alias[module]

    if module not in blacklist:
        command = 'whereis ' + module               # build whereis command
        result = invoke(command)                    # and run it
        if result.split( ':' )[1] != '\n':          # fetch result
            return True     # installed
        return False        # not installed!
    return True             # blacklisted

def installPackage( package ):
    if checkModule( package ):
        return False        # already installed
    else:                   # install package
        return invoke( 'apt-get -y install ' + package ) 

def installPackages( packages ): # only alias function...
    installed = False
    for package in packages:
        if installPackage( package ):
            installed = True
    if installed:
        return True 
    return False

def shutdown():
    exit()
    quit()

if __name__ == '__main__':

    checkRoot()                           # check for root
    OS           = checkOS()              # will return used OS!
    GIT_DIR      = checkGitDir()          # save current working path!
    DISTRIBUTION = checkDistribution()    # will return used ditribution!

    username = raw_input( 'Your Username [poisonweed]: ' )
    if username == '':
        username = 'poisonweed'

    if raw_input( 'Install Admin Tools? [Y/n]:' ) in [ 'y', 'Y' ]:
        packages = [
            'aptitude',
            'curl',
            'emacs',
            'gparted',
            'htop',
            'links2',
            'python-software-properties',
            'slurm',
            'tmux',
            'xclip',
            'nmap',
        ]

        installPackages( packages )

    if raw_input( 'Install Android Tools? [Y/n]:' ) in [ 'y', 'Y' ]:
        packages = [
            'android-tools-adb',
            'android-tools-adbd',
            'android-tools-fastboot',
        ]

        installPackages( packages )
    
    if raw_input( 'Install OpenSSH Server? [Y/n]:' ) in [ 'y', 'Y' ]:
        packages = [
            'openssh-server',
        ]

        installPackages( packages )
        hostPort = invoke( "cat /etc/ssh/sshd_config | grep Port | cut -d ' ' -f 2" ).strip()
        
        if hostPort != '50505':
            invoke( "sed -i 's/Port 22$/Port 50505/' /etc/ssh/sshd_config" )

        for user in [ 'root', username ]:
            if user == 'root': 
                userpath = '/root'
            else:
                userpath = '/home/' + user

            if not invoke( 'cat ' + userpath + '/.ssh/id_rsa.pub' ):
                invoke( "ssh-keygen -t rsa -f " + userpath + "/.ssh/id_rsa.pub -P ''" )
                invoke( 'cat ' + userpath + '/.ssh/id_rsa.pub |  xclip -selection clipboard' )
                raw_input( 'you have to copy your public ssh key to the server! ( already in clipboard )\nEnter to continue!' )

    if raw_input( 'Install Terminology? [Y/n]:' ) in [ 'y', 'Y' ]:
        
        package = 'terminology'

        if not checkModule( package ):
            invoke( 'add-apt-repository ppa:enlightenment-git/ppa' )
            invoke( 'apt-get update' )
            installPackage( package )

    if raw_input( 'Install Git? [Y/n]:' ) in [ 'y', 'Y' ]:
        invoke( 'mkdir -p /home/'+user+'/git/EXTERNAL' )
        if installPackage( 'git' ):
            invoke( 'git config --global user.name ' + username )
            invoke( 'git config --global user.email deathpoison.dc@gmail.com' )

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

    if raw_input( 'Install Dotfiles? [Y/n]:' ) in [ 'y', 'Y' ]:
        for user in [ 'root', username ]:
            if user == 'root': 
                userpath = '/root'
            else:
                userpath = '/home/' + user

            if invoke( 'ls ' + userpath + '/.bashrc 2>/dev/null' ):
                files = [
                    {   
                        'type': 'file',
                        'target': GIT_DIR + '/dotfiles/bash_aliases',
                        'destination': userpath + '/.bash_aliases',
                    }, {
                        'type': 'file',
                        'target': GIT_DIR + '/dotfiles/shell_prompt.sh',
                        'destination': userpath + '/.shell_prompt',
                    }, {
                        'type': 'file',
                        'target': GIT_DIR + '/dotfiles/tmux_prompt.sh',
                        'destination': userpath + '/.tmux_prompt',
                    }, {
                        'type': 'file',
                        'target': GIT_DIR + '/dotfiles/tmux.conf',
                        'destination': userpath + '/.tmux.conf',
                    }, {
                        'type': 'dir',
                        'target': GIT_DIR + '/dotfiles/vim',
                        'destination': userpath + '/.vim',
                    }, {
                        'type': 'file',
                        'target': GIT_DIR + '/dotfiles/vimrc',
                        'destination': userpath + '/.vimrc',
                    },
                ]

                for file in files:
                    if file['type'] == 'file':
                        copy( file['target'], file['destination'], user, True )
                    elif file['type'] == 'dir':
                        if copyDir( file['target'], file['destination'], user ) and file['target'] == GIT_DIR + '/dotfiles/vim':
                            invoke( 'git clone https://github.com/gmarik/Vundle.vim.git ' + userpath + '/.vim/bundle/Vundle.vim 2>/dev/null' )
                
                invoke( 'mkdir ' + userpath + '/git 2>/dev/null' )     
                invoke( 'mkdir ' + userpath + '/git/EXTERNAL 2>/dev/null' ) 

                if not invoke( 'ls ' + userpath + '/git/EXTERNAL/fonts 2>/dev/null' ):
                    invoke( 'git clone https://github.com/powerline/fonts.git ' + userpath + '/git/EXTERNAL/fonts 2>/dev/null' )
                    invoke( 'cd ' + userpath + '/git/EXTERNAL/fonts; ./install.sh; fc-cache -f -v 1>/dev/null' )

                if not invoke( "cat  " + userpath + "/.bashrc | grep '.bash_aliases'" ):
                    invoke( 'echo "if [ -f ' + userpath + '/.bash_aliases ]; then" >> ' + userpath + '/.bashrc' )
                    invoke( 'echo "    . ' + userpath + '/.bash_aliases" >> ' + userpath + '/.bashrc' )
                    invoke( 'echo "fi" >> ' + userpath + '/.bashrc' )

                invoke( 'vim +PluginInstall +qall' )

    if raw_input( 'Install NIM-Lang? [Y/n]' ) in [ 'y', 'Y' ]:

        package = 'nim'

        if not checkModule( package ):
            invoke( 'cd /home/'+user+'/git/EXTERNAL/ && git clone https://github.com/nim-lang/Nim.git' )
            invoke( 'cd Nim' )
            invoke( 'git clone --depth 1 https://github.com/nim-lang/csources' )
            invoke( 'cd csources && sh build.sh' )
            invoke( 'cd ..' )
            invoke( 'bin/nim c koch' )
            invoke( './koch boot -d:release' )
            invoke( 'cd /home/'+user+'/git/EXTERNAL && git clone https://github.com/nim-lang/nimble.git' )
            invoke( 'cd nimble' )
            invoke( 'source /home/'+user+'/.bash_aliases' )
            invoke( 'nim -d:release c -r src/nimble -y install' )
            invoke( 'source /home/'+user+'/.bash_aliases' )



    if DISTRIBUTION in [ 'Ubuntu', 'Debian' ]:
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
