##[

 Script: buildEnvironment
 --------------------------

 Script usedto import neccessary VARS in Modules

 ::
   v0.2 - 30.05.2017 - 17:00
        - added docStrings

   v0.1 - init Version

 :Author: **LimeBlack ~ David Crimi**

]##
#[
when isMainModule:
  import tables
  let vars: Table = {"USER":}.toTable
]#

try:
  echo "need to check if vars exists"
except:
  return false

let USER    = vars.user
let HOME    = vars.home
let ARCH    = vars.arch
let PATH    = vars.path
let DIST    = vars.dist
let PKG_MNG = vars.pkg_mng
let PWD     = vars.pwd
let FORCE   = vars.force
let SILENT  = vars.silent

