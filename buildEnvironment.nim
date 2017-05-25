#[ 
when isMainModule:
  import tables
  let vars: Table = {"USER":}.toTable
]#

try:
  echo "need to check if vars exists"
except:
  return false

let USER   = vars.user ## vars["USER"]
let HOME   = vars.home ## vars["HOME"]
let ARCH   = vars.arch ## vars["ARCH"]
let PATH   = vars.path ## vars["PATH"]
let DIST   = vars.dist ## vars["DIST"]
let PWD    = vars.pwd ## vars["PWD"]
let FORCE  = vars.force ## vars["FORCE"]
let SILENT = vars.silent ## vars["SILENT"]

