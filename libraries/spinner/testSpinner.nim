#from system import stdout, isMainModule, ... dont try to import SYSTEM!!!
from os import sleep
from threadpool as tp import spawn, sync # as tsync  <- does not work!

from spinner import Spinner, startSpinner, stopSpinner, spawnSpinner

when isMainModule:
  
  let sp = Spinner( 
    spinner: "clock", 
    progressLabel: "Installing VIM-Plugins:",
    doneText: "DONE!", 
    abortText: "Stopped", 
    defaultDelay: 75, 
    stream: stdout 
  )

  spawnSpinner sp
  
  sleep( 2000 )         # do some heavy stuff now!
  
  spinner.stopSpinner() # stop spinnerThread
  sync()                # make sure thread is finished
  
  quit()