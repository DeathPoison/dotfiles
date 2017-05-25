from os
import walkFiles

#from re
#import re, contains, escapeRe, find, findAll, replacef
import re

let DEBUG: bool = false

when isMainModule:

  var MODULES: seq[ string ] = @[] # hold list of available modules
  
  var argumentString: string = "user: USER, path: PATH, home: HOME, pwd: PWD, arch: ARCH, dist: DIST, silent: SILENT, force: FORCE"
  var installContent: string

  let importFile  = open("importModules.nim",  fmWrite)
  let installFile = open("installModules.nim", fmWrite)

  # does not need to initiliase this value, will do it in installer.nim
  #importFile.write("var MODULES: seq[ string ] = @[]" & "\n" & "\n")

  ## create: import file
  for file in walkFiles("modules/*.nim"):
    let moduleName: string = replacef(file, re"modules/*([a-zA-Z0-9]*).nim$", "$1")
    MODULES.add( moduleName )
    importFile.write("MODULES.add(\"" & moduleName & "\")\n")
    importFile.write("import " & file[0..^5] & "\n\n")

  importFile.close

  ## create: install file
  for module in MODULES:
    ## TODO replace table with DotfileModuleAttributes 
    # e.g.: DotfileModuleAttributes( user: USER, path: PATH, home: HOME, pwd: PWD )
    installContent = "discard " & module & ".install(DotfileModuleAttributes(" & argumentString & "))"
    if DEBUG: 
      echo "Will add to installModules.nim: " & installContent
    installFile.write( installContent & "\n" )

  installFile.close
