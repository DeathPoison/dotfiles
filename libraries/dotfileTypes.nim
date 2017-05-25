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
    dist*: string
    force*: bool
    silent*: bool

  ## Handle Module Requirements ~ Dependencies
  DependencieType* = enum
    command, directory, file, service, package

  Dependencie* = object
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
    module*: string
    dependencies*: seq[ Dependencie ]
