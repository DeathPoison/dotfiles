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
let PATH   = vars.path ## vars["PATH"]
let PWD    = vars.pwd ## vars["PWD"]
let FORCE  = vars.force ## vars["FORCE"]
let SILENT = vars.silent ## vars["SILENT"]

