import
  nimgame2 / [
    assets,
    entity,
    nimgame,
    texturegraphic,
    tilemap,
    settings,
    types,
  ],
  data


type
  Map* = ref object of TileMap

  Tile {.pure.} = enum
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

  Triad = array[0..2, array[0..2, Tile]]


converter toInt(tile: Tile): int =
  int tile


const
  UD    = [ [Tile.wL , Tile.flr, Tile.wR ],
            [Tile.wL , Tile.flr, Tile.wR ],
            [Tile.wL , Tile.flr, Tile.wR ] ]
  LR    = [ [Tile.wU , Tile.wU , Tile.wU ],
            [Tile.flr, Tile.flr, Tile.flr],
            [Tile.wD , Tile.wD , Tile.wD ] ]
  UL    = [ [Tile.tUL, Tile.flr, Tile.wR ],
            [Tile.flr, Tile.flr, Tile.wR ],
            [Tile.wU , Tile.wD , Tile.cUL] ]
  UR    = [ [Tile.wL , Tile.flr, Tile.wR ],
            [Tile.wL , Tile.flr, Tile.flr],
            [Tile.cUR, Tile.wD , Tile.wD ] ]
  DL    = [ [Tile.wU , Tile.wU , Tile.cDL],
            [Tile.flr, Tile.flr, Tile.wR ],
            [Tile.wD , Tile.tDL, Tile.wR ] ]
  DR    = [ [Tile.cDR, Tile.wU , Tile.wU ],
            [Tile.wL , Tile.flr, Tile.flr],
            [Tile.wL , Tile.flr, Tile.tDR] ]
  UDL   = [ [Tile.tUL, Tile.flr, Tile.wR ],
            [Tile.flr, Tile.flr, Tile.wR ],
            [Tile.tDL, Tile.flr, Tile.wR ] ]
  UDR   = [ [Tile.wL , Tile.flr, Tile.tUR],
            [Tile.wL , Tile.flr, Tile.flr],
            [Tile.wL , Tile.flr, Tile.tDR] ]
  ULR   = [ [Tile.tUL, Tile.flr, Tile.tUR],
            [Tile.flr, Tile.flr, Tile.flr],
            [Tile.wD , Tile.wD , Tile.wD ] ]
  DLR   = [ [Tile.wU , Tile.wU , Tile.wU ],
            [Tile.flr, Tile.flr, Tile.flr],
            [Tile.tDL, Tile.flr, Tile.tDR] ]
  UDLR  = [ [Tile.tUL, Tile.flr, Tile.tUR],
            [Tile.flr, Tile.flr, Tile.flr],
            [Tile.tDL, Tile.flr, Tile.tDR] ]
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
    idx.h >= MapTriadHeight)


proc set*(map: Map, idx: Dim, triad: Triad) =
  if invalidTriadIndex idx:
    echo "ERROR: triad index is invalid: ", idx
    return
  let start = idx * 3
  for y in 0..2:
    for x in 0..2:
      map.map[start.h + y][start.w + x] = triad[y][x]


proc init*(map: Map) =
  init TileMap(map)
  map.graphic = gfxData["tiles"]
  map.initSprite SpriteDim, SpriteOffset
  map.clear()


proc free*(map: Map) =
  discard


proc newMap*(): Map =
  new result, free
  init result

