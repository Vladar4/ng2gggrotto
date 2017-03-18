import
  random,
  nimgame2 / [
    assets,
    entity,
    nimgame,
    texturegraphic,
    tilemap,
    settings,
    types,
    utils
  ],
  data


type
  Map* = ref object of TileMap
    exitU*, exitD*, exitL*, exitR*: tuple[x, y: int]
    spawnPoints*: seq[tuple[x, y: int]]

  Tile = enum
    flr # floor
    non
    u0
    und
    wU  # wall up
    wD  # wall down
    wL  # wall left
    wR  # wall right
    tUL # turn up-left
    tUR # turn up-right
    tDL # turn down-left
    tDR # turn down-right
    cUL # corner up-left
    cUR # corner up-right
    cDL # corner down-left
    cDR # corner down-right

  Triad = enum
    UND, NONE, U, D, L, R, UD, LR, UL, UR, DL, DR, UDL, UDR, ULR, DLR, UDLR


converter toInt(tile: Tile): int =
  int tile


const
  Triads = [
    [ [und, und, und],  # UND
      [und, und, und],
      [und, und, und] ],
    [ [non, non, non],  # NONE
      [non, non, non],
      [non, non, non] ],
    [ [wL , flr, wR ],  # U
      [wL , flr, wR ],
      [cDL, wD , cDR] ],
    [ [cUL, wU , cUR],  # D
      [wL , flr, wR ],
      [wL , flr, wR ] ],
    [ [wU , wU , cUR],  # L
      [flr, flr, wR ],
      [wD , wD , cDR] ],
    [ [cUL, wU , wU ],  # R
      [wL , flr, flr],
      [cDL, wD , wD ] ],
    [ [wL , flr, wR ],  # UD
      [wL , flr, wR ],
      [wL , flr, wR ] ],
    [ [wU , wU , wU ],  # LR
      [flr, flr, flr],
      [wD , wD , wD ] ],
    [ [tUL, flr, wR ],  # UL
      [flr, flr, wR ],
      [wD , wD , cDR] ],
    [ [wL , flr, tUR],  # UR
      [wL , flr, flr],
      [cDL, wD , wD ] ],
    [ [wU , wU , cUR],  # DL
      [flr, flr, wR ],
      [tDL, flr, wR ] ],
    [ [cUL, wU , wU ],  # DR
      [wL , flr, flr],
      [wL , flr, tDR] ],
    [ [tUL, flr, wR ],  # UDL
      [flr, flr, wR ],
      [tDL, flr, wR ] ],
    [ [wL , flr, tUR],  # UDR
      [wL , flr, flr],
      [wL , flr, tDR] ],
    [ [tUL, flr, tUR],  # ULR
      [flr, flr, flr],
      [wD , wD , wD ] ],
    [ [wU , wU , wU ],  # DLR
      [flr, flr, flr],
      [tDL, flr, tDR] ],
    [ [tUL, flr, tUR],  # UDLR
      [flr, flr, flr],
      [tDL, flr, tDR] ]
  ]
  TriadsAll = {NONE, U, D, L, R, UD, LR, UL, UR, DL, DR, UDL, UDR, ULR, DLR, UDLR}
  TriadsU   = {U, UD, UL, UR, UDL, UDR, ULR, UDLR}
  TriadsD   = {D, UD, DL, DR, UDL, UDR, DLR, UDLR}
  TriadsL   = {L, LR, UL, DL, UDL, ULR, DLR, UDLR}
  TriadsR   = {R, LR, UR, DR, UDR, ULR, DLR, UDLR}
  TriadsNoU = {NONE, D, L, R, LR, DL, DR, DLR}
  TriadsNoD = {NONE, U, L, R, LR, UL, UR, ULR}
  TriadsNoL = {NONE, U, D, R, UD, UR, DR, UDR}
  TriadsNoR = {NONE, U, D, L, UD, UL, DL, UDL}
  MapTileWidth*   = 48
  MapTileHeight*  = 30
  MapTriadWidth*  = MapTileWidth  div 3
  MapTriadHeight* = MapTileHeight div 3
  MapCenter*: Dim = (MapTriadWidth div 2, MapTriadHeight div 2)
  MinimalMapSize  = int(MapTriadWidth * MapTriadHeight * 0.75)


type
  TriadGrid = array[MapTriadHeight, array[MapTriadWidth, Triad]]


template triadToTile(x, y: int): tuple[x, y: int] =
  ( x * 3 + 1,
    y * 3 + 1 )


proc init(t: var TriadGrid) =
  for y in 0..<MapTriadHeight:
    for x in 0..<MapTriadWidth:
      t[y][x] = UND


proc clear*(map: Map) =
  map.map.setLen 0
  for y in 0..<MapTileHeight:
    var line: seq[int] = @[]
    for x in 0..<MapTileWidth:
      line.add und
    map.map.add line


template invalidTriadIndex(idx: Dim): bool =
  ( idx.w < 0 or
    idx.h < 0 or
    idx.w >= MapTriadWidth or
    idx.h >= MapTriadHeight )


proc set*(map: Map, idx: Dim, triad: Triad) =
  if invalidTriadIndex idx:
    echo "ERROR: triad index is invalid: ", idx
    return
  let start = idx * 3
  for y in 0..2:
    for x in 0..2:
      map.map[start.h + y][start.w + x] = Triads[int(triad)][y][x]


proc generate*(t: var TriadGrid,
               x = MapCenter.w,
               y = MapCenter.h) =
  var choice = TriadsAll - {NONE}
  if (x == MapCenter.w) and (y == MapCenter.h):
    choice = choice - {U, D, L, R}

  # top
  if y > 0:
    let top = t[y-1][x]
    if top != UND:
      if top in TriadsD:
        choice = choice - TriadsNoU
      else:
        choice = choice - TriadsU
  else: # top border
    choice = choice - TriadsU

  # down
  if y < (MapTriadHeight - 1):
    let down = t[y+1][x]
    if down != UND:
      if down in TriadsU:
        choice = choice - TriadsNoD
      else:
        choice = choice - TriadsD
  else: # bottom border
    choice = choice - TriadsD

  # left
  if x > 0:
    let left = t[y][x-1]
    if left != UND:
      if left in TriadsR:
        choice = choice - TriadsNoL
      else:
        choice = choice - TriadsL
  else: # left border
    choice = choice - TriadsL

  # right
  if x < (MapTriadWidth - 1):
    let right = t[y][x+1]
    if right != UND:
      if right in TriadsL:
        choice = choice - TriadsNoR
      else:
        choice = choice - TriadsR
  else: # right border
    choice = choice - TriadsR

  # leave space for the interface
  if (y == 0) and (x == 6):
    choice = choice - TriadsL
  elif (y == 1) and (x in 0..5):
    choice = choice - TriadsU

  if choice == {}:
    # should never happen
    choice = {UND}

  t[y][x] = random choice

  # recursive
  let current = t[y][x]
  if (current in TriadsU) and (y > 0):
    if t[y-1][x] == UND:
      t.generate(x, y-1)
  if (current in TriadsD) and (y < (MapTriadHeight - 1)):
    if t[y+1][x] == UND:
      t.generate(x, y+1)
  if (current in TriadsL) and (x > 0):
    if t[y][x-1] == UND:
      t.generate(x-1, y)
  if (current in TriadsR) and (x < (MapTriadWidth - 1)):
    if t[y][x+1] == UND:
      t.generate(x+1, y)


proc generate*(map: Map, minimalSize = MinimalMapSize) =
  var t: TriadGrid
  init t
  generate t

  # check size
  var counter = 0
  for y in 0..<MapTriadHeight:
    for x in 0..<MapTriadWidth:
      if t[y][x] == UND:
        t[y][x] = NONE
      else:
        inc counter
  if counter < minimalSize:
    map.generate(minimalSize)
    return

  # create exits
  type Route = enum rU, rD, rL, rR
  proc addRoute(t: Triad, route: Route): Triad =
    result = t
    var choice = TriadsAll - {NONE}
    case route:
    of rU:
      if t in TriadsU:
        return
      choice = choice - TriadsNoU
      choice =  if t in TriadsD: choice * TriadsD
                else: choice * TriadsNoD
      choice =  if t in TriadsL: choice * TriadsL
                else: choice * TriadsNoL
      choice =  if t in TriadsR: choice * TriadsR
                else: choice * TriadsNoR
    of rD:
      if t in TriadsD:
        return
      choice = choice - TriadsNoD
      choice =  if t in TriadsU: choice * TriadsU
                else: choice * TriadsNoU
      choice =  if t in TriadsL: choice * TriadsL
                else: choice * TriadsNoL
      choice =  if t in TriadsR: choice * TriadsR
                else: choice * TriadsNoR
    of rL:
      if t in TriadsL:
        return
      choice = choice - TriadsNoL
      choice =  if t in TriadsU: choice * TriadsU
                else: choice * TriadsNoU
      choice =  if t in TriadsD: choice * TriadsD
                else: choice * TriadsNoD
      choice =  if t in TriadsR: choice * TriadsR
                else: choice * TriadsNoR
    of rR:
      if t in TriadsR:
        return
      choice = choice - TriadsNoR
      choice =  if t in TriadsU: choice * TriadsU
                else: choice * TriadsNoU
      choice =  if t in TriadsD: choice * TriadsD
                else: choice * TriadsNoD
      choice =  if t in TriadsL: choice * TriadsL
                else: choice * TriadsNoL
    result = random choice

  var
    up: seq[int] = @[]
    down: seq[int] = @[]
    left: seq[int] = @[]
    right: seq[int] = @[]
  for x in 0..<MapTriadWidth:
    if t[0][x] != NONE:
      up.add x
    if t[MapTriadHeight-1][x] != NONE:
      down.add x
  for y in 0..<MapTriadHeight:
    if t[y][0] != NONE:
      left.add y
    if t[y][MapTriadWidth-1] != NONE:
      right.add y

  # check for exits
  if (up.len < 1) or
     (down.len < 1) or
     (left.len < 1) or
     (right.len < 1):
    map.generate minimalSize
    return

  proc middle(s: seq[int]): int =
    let mid = s.len div 2
    random([s[mid-1], s[mid]])

  # add exits
  block exitU:
    let x = middle up
    t[0][x] = addRoute(t[0][x], rU)
    map.exitU = triadToTile(x, 0)
  block exitD:
    let x = middle down
    t[MapTriadHeight-1][x] = addRoute(t[MapTriadHeight-1][x], rD)
    map.exitD = triadToTile(x, MapTriadHeight-1)
  block exitL:
    let y = middle left
    t[y][0] = addRoute(t[y][0], rL)
    map.exitL = triadToTile(0, y)
  block exitR:
    let y = middle right
    t[y][MapTriadWidth-1] = addRoute(t[y][MapTriadWidth-1], rR)
    map.exitR = triadToTile(MapTriadWidth-1, y)

  # fill map
  map.clear()
  for y in 0..<MapTriadHeight:
    for x in 0..<MapTriadWidth:
      map.set((x, y), t[y][x])

  # fill spawn points
  map.spawnPoints = @[]
  let
    clearCenterUp = MapTileHeight div 2 - 2
    clearCenterDown = MapTileHeight div 2 + 4
    clearCenterLeft = MapTileWidth div 2 - 2
    clearCenterRight = MapTileWidth div 2 + 4
  for y in 3..<(MapTileHeight-3):
    for x in 3..<(MapTileWidth-3):
      if ((y < clearCenterUp) or (y > clearCenterDown)) or
         ((x < clearCenterLeft) or (x > clearCenterRight)):
        if map.map[y][x] == flr:
          map.spawnPoints.add((x, y))


proc init*(map: Map) =
  init TileMap(map)
  map.graphic = gfxData["tiles"]
  map.initSprite SpriteDim, SpriteOffset
  map.generate()


proc free*(map: Map) =
  discard


proc newMap*(): Map =
  new result, free
  init result

