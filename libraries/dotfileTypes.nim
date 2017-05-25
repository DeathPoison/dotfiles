## TODO add descriptions!

type
  # Container for files being used by this app
  DotfileObj* = object           ## With the creation of a referenze
    name*: string
    isDir*: bool                 ## this object transforms into a
    target*: string              ## immutable procedure, dont need it now!
    overwrite*: bool
    destination*: string

  DotfileModuleAttributes* = object
    pwd*: string
    user*: string
    home*: string
    path*: string
    arch*: string
    force*: bool
    silent*: bool

  ## Handle Module Requirements ~ Dependencies
  DependencieType* = enum
    command, directory, file, service

  Dependencie* = object
    name*: string
    description*: string
    case kind*: DependencieType
    of command, service:
      command*: string
      arguments*: seq[ string ]
    else:
      path*: string

  Dependencies* = object
    module*: string
    dependencies*: seq[ Dependencie ]