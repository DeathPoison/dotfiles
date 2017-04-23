#[

	Inceptions - Exception Lib

	Additional Exception Types
]#

type
  # few  error types
  WrongOS*            = object of Exception
  
  ## used in my dotfiles
  CantInstallPackage* = object of Exception

  ## TODO move to arnold lib!!!
  CmdDoesNotExists*   = object of Exception
  CmdRaisesError*     = object of Exception