#[
  Little Snippet for setting the corrent entvironment to test the Dotfiles-Modules
]#

from os import getEnv

# command executor
from libraries/arnold/arnold
import execCommand, getPackageManager

from libraries/dotfile
import getArch, getDistribution


let USER: string = "poisonweed"
#let PATH: string = "/home/poisonweed/.yarn/bin:/home/poisonweed/.config/yarn/global/node_modules/.bin:/home/poisonweed/.cargo/bin:/home/poisonweed/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/usr/lib/jvm/java-8-oracle/bin:/usr/lib/jvm/java-8-oracle/db/bin:/usr/lib/jvm/java-8-oracle/jre/bin:/home/poisonweed/git/EXTERNAL/Nim/bin/:/home/poisonweed/.nimble/bin/:/home/poisonweed/bin"
let PATH: string = execCommand( "echo $PATH", user = USER, wantResult = true, needEnviroment = true )
#let PATH: string = os.getEnv("PATH")
let DIST: string = getDistribution()
let PKG_MNG: string = getPackageManager()
let ARCH: string = getArch()
let HOME: string = "/home/poisonweed"
let PWD: string = "/home/poisonweed/git/EXTERNAL/dotfiles"
let SILENT: bool = false
let FORCE: bool = false

echo "----------------------->" & PKG_MNG
