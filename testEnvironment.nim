#[
  Little Snippet for setting the corrent entvironment to test the Dotfiles-Modules
]#

from os import getEnv

# command executor
from libraries.arnold.arnold
import execCommand

from libraries.dotfile
import getArch, getDistribution, getPackageManager


let USER: string = "poisonweed"
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