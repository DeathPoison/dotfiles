##[

 Library: Inception
 -----------------------

 Some Additional Exception Types

 ::
   v0.1 - init 

 :Author: **LimeBlack ~ David Crimi**
 :Useful: 
    `Philanthrop <../philanthrop.html>`_

]##

type
  WrongOS*            = object of Exception  ## Raised if wrong OS will be detected
  CantInstallPackage* = object of Exception  ## Arnold: Raised if package can not be installed
  CmdDoesNotExists*   = object of Exception  ## Arnold: Need to move
  CmdRaisesError*     = object of Exception  ## Arnold: Need to move
