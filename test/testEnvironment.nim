#[
  Little Snippet for setting the corrent entvironment to test the Dotfiles-Modules

  NOT REALLY A TEST FILE...

  TODO: write some
]#

from os import getEnv

# command executor
from "../libraries/arnold/arnold"
import execCommand, getPackageManager

from "../libraries/dotfileHelper"
import getArch, getDistribution


let USER: string = "pi"
let PATH: string = execCommand( "echo $PATH", user = USER, wantResult = true, needEnviroment = true )
#let PATH: string = os.getEnv("PATH")
let DIST: string = getDistribution()
let PKG_MNG: string = getPackageManager()
let ARCH: string = getArch()
let HOME: string = "/home/" & USER
let PWD: string = HOME & "/git/.EXTERNAL/dotfiles"
let SILENT: bool = false
let FORCE: bool = false

echo "----------------------->" & PKG_MNG
