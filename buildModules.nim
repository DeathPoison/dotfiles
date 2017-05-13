from os
import walkFiles

from re
import re, contains, escapeRe, find, findAll, replacef

when isMainModule:

  var MODULES: seq[ string ] = @[] # hold list of available modules
  
  var argumentString: string = """"USER":USER, "PATH":PATH, "HOME":HOME, "PWD":PWD"""    ## , "SILENT":SILENT, "FORCE":FORCE
  var installContent: string

  let importFile  = open("importModules.nim",  fmWrite)
  let installFile = open("installModules.nim", fmWrite)

  # does not need to initiliase this value, will do it in installer.nim
  #importFile.write("var MODULES: seq[ string ] = @[]" & "\n" & "\n")

  ## create: import file
  for file in walkFiles("modules/*.nim"):
    MODULES.add( replacef(file, re"modules/*([a-zA-Z]*).nim$", "$1") )
    importFile.write("MODULES.add(\"" & replacef(file, re"modules/*([a-zA-Z]*).nim$", "$1") & "\")\n")
    importFile.write("import " & file[0..^5] & "\n" & "\n")
  importFile.close

  ## create: install file
  for module in MODULES:
    installContent = "discard " & module & ".install({" & argumentString & "}.toTable)"
    echo "Will add to installModules.nim: " & installContent
    installFile.write( installContent & "\n" )

  installFile.close
