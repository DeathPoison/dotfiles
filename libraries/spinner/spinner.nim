from os import sleep
from posix import SIGINT, SIGTERM, onSignal
from tables import toTable, `[]`
from unicode import Rune, utf8
from terminal import hideCursor, showCursor, eraseLine
from threadpool import spawn, sync

#[
  Thanks to https://github.com/helloIAmPau/node-spinner

  Should describe what this lib will do, but I dont care - for the moment!
]#

## TODO add spinners to nimble!

type
  Spinner* = object
    spinner*:          string
    progressLabel*: string
    progressText*:  string   
    doneText*:      string
    abortText*:     string
    defaultDelay*:  int
    stream*:        File

var shouldStop: bool = true
var interrupted: bool = false

proc getUnicodeLenght( letter: string ): int =
  result = letter.len
  if result < 4:
    result = 1
  if result == 4:
    result = 2
  return result

proc getSymbol( choosenSymbol: string = "clock" ): string = 
  var spinners= {
    "clock":      r"🕐🕜🕑🕝🕒🕞🕓🕟🕔🕠🕕🕡🕖🕢🕗🕣🕘🕤🕙🕥🕚🕦🕛🕧",
    "fish":       r"⧕⧒⧓⧑⧔",
    "moon":       r"🌑🌒🌓🌔🌕🌝🌖🌗🌘🌚",
    "globe":      r"🌍🌎🌏",
    "lines":      r"☱☲☴",
    "cubes1":     r"⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏",
    "cubes2":     r"⠋⠙⠚⠞⠖⠦⠴⠲⠳⠓",
    "cubes3":     r"⠄⠆⠇⠋⠙⠸⠰⠠⠰⠸⠙⠋⠇⠆",
    "dots1":      r"⣾⣽⣻⢿⡿⣟⣯⣷",
    "dots2":      r"⢹⢺⢼⣸⣇⡧⡗⡏",
    "dots3":      r"⠁⠁⠉⠙⠚⠒⠂⠂⠒⠲⠴⠤⠄⠄⠤⠠⠠⠤⠦⠖⠒⠐⠐⠒⠓⠋⠉⠈⠈",
    "dots4":      r"⠋⠙⠚⠒⠂⠂⠒⠲⠴⠦⠖⠒⠐⠐⠒⠓⠋",
    "dots5":      r"⠁⠉⠙⠚⠒⠂⠂⠒⠲⠴⠤⠄⠄⠤⠴⠲⠒⠂⠂⠒⠚⠙⠉⠁",
    "dots6":      r"⠈⠉⠋⠓⠒⠐⠐⠒⠖⠦⠤⠠⠠⠤⠦⠖⠒⠐⠐⠒⠓⠋⠉⠈",
    "billard":    r"❶❷❸❹❺❻❼❽❾",
    "square":     r"■□▪▫",
    "vertical":   r"▉▊▋▌▍▎▏▎▍▌▋▊▉",
    "horizontal": r"▁▃▄▅▆▇█▇▆▅▄▃",
    
    # "": r"123456789",
    # "": r"DAVE",
    # "": r"⧖⧗⧖",
    # "": r"|/-\\",
    # "": r"⠂-–—–-",
    # "": r"◐◓◑◒",
    # "": r"◴◷◶◵",
    # "": r"◡◡⊙⊙◠◠",
    # "": r"◰◳◲◱",
    # "": r"◢◣◤◥",
    # "": r"▖▘▝▗",
    # "": r"▌▀▐▄",
    # "": r"←↖↑↗→↘↓↙",
    # "": r"┤┘┴└├┌┬┐",
    # r"": ".oO°Oo.",
    # r"": ".oO@*",
    # "": r"⢄⢂⢁⡁⡈⡐⡠",
    # "": r"⠁⠂⠄⡀⢀⠠⠐⠈",
  }.toTable
  result = spinners[choosenSymbol]  
  return result

proc alternateOnTick( msg: string, output: File = stdout, progressLabel: string = "", progressText: string = "" ) =
  output.eraseLine
  output.write progressLabel & " "
  output.write msg
  output.write " " & progressText
  output.flushFile

proc defaultOnTick( msg: string, output: File = stdout ) =
  let charLenght = getUnicodeLenght( msg )

  for y in 1..charLenght:
    output.write "\b"

  output.write msg
  output.flushFile


proc startSpinner*( sp: Spinner ) =
  var mySpinner: Spinner = sp
  let symbol: string = getSymbol(mySpinner.spinner)
  
  var label = sp.progressLabel
  if isNil( label ):
    label = "Progress:"

  var text  = sp.progressText
  if isNil( text ):
    text = ""

  # set stopFlag to false
  shouldStop = false

  # hide terminal cursor
  hideCursor()

  while true:
    for letter in symbol.utf8:
      #defaultOnTick( letter )
      alternateOnTick( letter, progressLabel = label, progressText = text )
      mySpinner.stream.flushFile
      sleep(mySpinner.defaultDelay)

    # add stop condition
    if shouldStop or interrupted:
      break

  if mySpinner.abortText == "":
    mySpinner.abortText = "Aborted"

  if interrupted: 
    mySpinner.doneText = mySpinner.abortText

  ## DONE - remove last icon and show DONEText followed by newline
  mySpinner.stream.eraseLine
  mySpinner.stream.write mySpinner.doneText & "\n"
  
  # unhide terminal cursor
  showCursor()

proc spawnSpinner*( sp: Spinner ) = 
  shouldStop = false
  spawn startSpinner sp

proc stopSpinner*() = shouldStop = true


# CTRL + C
onSignal( SIGINT, SIGTERM ):
  #stdout.write "\n\nYou Pressed CTRL + C\nClosing this Application..."
  echo "" # should i send this linebreak?

  if shouldStop: # just quit if not active
    quit()

  interrupted = true
  threadpool.sync()
  showCursor()
  quit()


when isMainModule:

  var sp: Spinner  = Spinner( 
    spinner: "clock", 
    doneText: "DONE!", 
    defaultDelay: 75, 
    stream: stdout 
  )

  stdout.write "Installing VIM-Plugins: "
  spawnSpinner( sp )
  sleep( 2000 )   # do some heavy stuff now!
  stopSpinner()   # stop spinnerThread
  threadpool.sync()          # make sure thread is finished

  #[
  for spinner in spinners:
    echo "Current Spinner: ", spinner
    stdout.write "Progress: "
    
    sp.spinner = spinner
    spawn startSpinner sp
    sleep( 2000 )   # do some heavy stuff now!
    stopSpinner()   # stop spinnerThread
    sync()          # make sure thread is finished
  ]#
