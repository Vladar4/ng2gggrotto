import
  nimgame2 / [
    entity,
    input,
    nimgame,
    texturegraphic,
    tween,
    types,
  ],
  data,
  map


const
  Framerate* = 1/12
  DefaultSpeed* = 0.5
  SpriteSize*: Dim = (20, 20)


type
  Control* {.pure.} = enum none, player, ai
  Direction* = enum dStay, dUp, dDown, dLeft, dRight
  MapPos* = tuple[x, y: int]

  Creature* = ref object of Entity
    control*: Control
    speed*: float
    prevDirection*: Direction
    tween: Tween[Creature,Coord]
    map*: Map
    mapPos*: MapPos


proc toCoord(pos: MapPos): Coord {.inline.} =
  (pos.x * SpriteDim.w + 1, pos.y * SpriteDim.h + 1)


proc toMapPos(pos: Coord, size = SpriteSize): MapPos {.inline.} =
  (int(pos.x / size.w.float), int(pos.y / size.h.float))


proc placeTo*(c: Creature, mapPos: MapPos) =
  c.mapPos = mapPos
  c.pos = mapPos.toCoord


proc init*(c: Creature, graphic: TextureGraphic, mapPos: MapPos, map: Map) =
  c.initEntity()
  c.tags.add("creature")
  c.graphic = graphic
  c.initSprite(SpriteSize)
  discard c.addAnimation("up",    toSeq(0..3),    Framerate)
  discard c.addAnimation("down",  toSeq(4..7),    Framerate)
  discard c.addAnimation("left",  toSeq(8..11),   Framerate)
  discard c.addAnimation("right", toSeq(12..15),  Framerate)
  c.center = (1, 1)
  c.speed = DefaultSpeed
  c.map = map
  c.placeTo(mapPos)


proc newCreature*(graphic: TextureGraphic, mapPos: MapPos, map: Map): Creature =
  new result
  init result, graphic, mapPos, map


proc dirAvailable(c: Creature, dir: Direction): bool =
  let
    x = c.mapPos.x
    y = c.mapPos.y
  return case dir:
    of dUp:
      if y < 1: false
      else: c.map.map[y-1][x] < 1
    of dDown:
      if y >= (MapTileHeight - 1): false
      else: c.map.map[y+1][x] < 1
    of dLeft:
      if x < 1: false
      else: c.map.map[y][x-1] < 1
    of dRight:
      if x >= (MapTileWidth - 1): false
      else: c.map.map[y][x+1] < 1
    else:
      true


proc move*(c: Creature, dir: Direction) =
  if c.map == nil:
    echo "ERROR: map is not initialized"
    return
  var
    anim: string
    mov: Coord
  case dir:
  of dStay:
    return
  of dUp:
    anim = "up"
    mov = (0.0, -c.sprite.dim.h.float)
  of dDown:
    anim = "down"
    mov = (0.0, c.sprite.dim.h.float)
  of dLeft:
    anim = "left"
    mov = (-c.sprite.dim.w.float, 0.0)
  of dRight:
    anim = "right"
    mov = (c.sprite.dim.w.float, 0.0)

  if c.tween == nil or not c.tween.playing:
    let
      newPos = c.pos + mov
      newMapPos = toMapPos(newPos)

    c.play(anim, 1)
    c.tween = newTween[Creature,Coord](
      c,
      proc(t: Creature): Coord = t.pos,
      proc(t: Creature, val: Coord) = t.pos = val
    )
    c.tween.setup(c.pos, newPos, c.speed, 0)
    c.tween.play()
    c.mapPos = newMapPos
    c.prevDirection = dir


method update*(c: Creature, elapsed: float) =
  c.updateEntity elapsed
  if c.tween != nil:
    c.tween.update elapsed
  case c.control:
  of Control.player:
    if moveUp.down and c.dirAvailable(dUp): c.move(dUp)
    elif moveDown.down and c.dirAvailable(dDown): c.move(dDown)
    elif moveLeft.down and c.dirAvailable(dLeft): c.move(dLeft)
    elif moveRight.down and c.dirAvailable(dRight): c.move(dRight)
    elif c.dirAvailable(c.prevDirection): c.move(c.prevDirection)
  else:
    discard

