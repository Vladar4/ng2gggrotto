import
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

  Tile = enum
    flr # floor
    u1
    u2
    u3
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
    UD, LR, UL, UR, DL, DR, UDL, UDR, ULR, DLR, UDLR


converter toInt(tile: Tile): int =
  int tile


const
  Triads = [
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
  TriadsAll = {UD, LR, UL, UR, DL, DR, UDL, UDR, ULR, DLR, UDLR}
  TriadsU   = {UD, UL, UR, UDL, UDR, ULR, UDLR}
  TriadsD   = {UD, DL, DR, UDL, UDR, DLR, UDLR}
  TriadsL   = {LR, UL, DL, UDL, ULR, DLR, UDLR}
  TriadsR   = {LR, UR, DR, UDR, ULR, DLR, UDLR}
  TriadsNoU = {LR, DL, DR, DLR}
  TriadsNoD = {LR, UL, UR, ULR}
  TriadsNoL = {UD, UR, DR, UDR}
  TriadsNoR = {UD, UL, DL, UDL}
  MapTileWidth    = 48
  MapTileHeight   = 30
  MapTriadWidth   = MapTileWidth  div 3
  MapTriadHeight  = MapTileHeight div 3


proc clear*(map: Map) =
  map.map.setLen 0
  for y in 0..<MapTileHeight:
    var line: seq[int] = @[]
    for x in 0..<MapTileWidth:
      line.add 0
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


proc init*(map: Map) =
  init TileMap(map)
  map.graphic = gfxData["tiles"]
  map.initSprite SpriteDim, SpriteOffset
  map.clear()
  for y in 0..<MapTriadHeight:
    for x in 0..<MapTriadWidth:
      var choice = TriadsAll
      if x == 0:
        choice = choice - TriadsL
      if y == 0:
        choice = choice - TriadsU
      if x == MapTriadWidth - 1:
        choice = choice - TriadsR
      if y == MapTriadHeight - 1:
        choice = choice - TriadsD
      map.set((x, y), random choice)


proc free*(map: Map) =
  discard


proc newMap*(): Map =
  new result, free
  init result

