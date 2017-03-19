import
  os


const
  NameLength* = 16


type
  Name* = array[NameLength, char]
  Hiscore* = object
    name*: Name
    score*: uint64


var
  hiscores*: array[10, Hiscore]
  hiscoresDir, hiscoresPath: string


proc toName*(str: string): Name =
  let lim = if str.high < NameLength: str.high else: NameLength - 1
  for i in 0..<NameLength:
    result[i] = ' '
  for i in 0..lim:
    result[i] = str[i]


proc toString*(name: Name): string =
  result = ""
  for c in name:
    result.add c


proc initHiscores*() =
  var
    f: File
    line: Hiscore
  let
    size = sizeof(line)

  hiscoresDir = getConfigDir().joinPath("gggrotto")
  hiscoresPath = hiscoresDir.joinPath("hiscores.dat")

  if f.open(hiscoresPath, fmRead, size):
    var i = 0
    while f.readBuffer(addr(line), size) == size:
      hiscores[i] = line
      inc i

  else:
    discard existsOrCreateDir(hiscoresDir)
    if not f.open(hiscoresPath, fmWrite, size):
      echo "ERROR: Can't create hiscores file in the ", hiscoresDir
      return

    for i in 0..9:
      line.name = toName("empty")
      line.score = 0
      discard f.writeBuffer(addr(line), size)

  f.close


proc writeHiscores*() =
  var
    f: File
    line: Hiscore
  let
    size = sizeof(line)

  if not f.open(hiscoresPath, fmWrite, size):
    echo "ERROR: Can't open hiscores file ", hiscoresPath
    return

  for i in 0..9:
    line = hiscores[i]
    discard f.writeBuffer(addr(line), size)

  f.close()


proc shiftScores(idx: int) =
  for i in countdown(9, idx + 1):
    hiscores[i] = hiscores[i-1]


proc checkForHiscore*(newScore: uint): int =
  result = -1
  for i in 0..9:
    if newScore > hiscores[i].score:
      shiftScores i
      hiscores[i].score = newScore
      result = i
      break

