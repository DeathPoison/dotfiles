##[
 Script: DotfileTypes
 ---------------------

 Holding Data-Types for Attributes and Dependencies from Modules

 :: 
  v0.3 - 30.05.2017 - 14:00
       - added missing DocStrings

  v0.2 - added DataType to hold Dependencies from Modules
  v0.1 - added DotfileObj and DotfileAttributes

 :Author: **LimeBlack ~ David Crimi**
 :Useful: 
    `Dotfile <dotfile.html>`_
    `Philanthrop <philanthrop.html>`_
]##

type
  DotfileObj* = object 
    ##[
      Object which is used to hold some files or directories 
      for copying to your home directory and setup your environment
    ]##
    name*: string
    isDir*: bool
    target*: string
    overwrite*: bool
    destination*: string

  DotfileModuleAttributes* = object
    ##[
      Object which is used to transport all neccessary VARS to the modules
      :PWD: Current working directory
      :USER: Current username
      :HOME: Path to HomeDir
      :PATH: PATH from user's environment
      :ARCH: Processor Architecture e.g. x64, i686
      :DIST: Current running linux distribution e.g. Ubuntu, Debian
      :FORCE: Force Mode - decide for user
      :SILENT: Silent Mode - prevent interactions with the user
    ]##
    pwd*: string
    user*: string
    home*: string
    path*: string
    arch*: string
    dist*: string
    force*: bool
    silent*: bool

  ## Handle Module Requirements ~ Dependencies
  DependencieType* = enum
    ## Possible Dependencie Types
    command, directory, file, service, package

  Dependencie* = object
    ## Object which is used to describe Module-Dependencies
    name*: string
    description*: string
    case kind*: DependencieType

    of command, service:
      command*: string
      arguments*: seq[ string ]

    of directory, file:
      path*: string

    of package:
      package*: string

    else: discard

  Dependencies* = object
    ## Object which holds a Module-Name and his collection of Dependencie-Objects
    module*: string
    dependencies*: seq[ Dependencie ]
