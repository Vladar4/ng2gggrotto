import
  nimgame2 / [
    collider,
    entity,
    nimgame,
    texturegraphic,
    tween,
    types,
  ],
  data,
  map


type
  Direction* = enum dStay, dUp, dDown, dLeft, dRight

  Creature* = ref object of Entity
    prevDirection*: Direction
    tween*: Tween[Creature,Coord]
    map*: Map
    mapPos*: MapPos


template framerate*(): float =
  (speed / 4)


proc placeTo*(c: Creature, mapPos: MapPos) =
  c.mapPos = mapPos
  c.pos = mapPos.toCoord


proc init*(c: Creature, graphic: TextureGraphic, mapPos: MapPos, map: Map) =
  c.initEntity()
  c.tags.add "creature"
  c.graphic = graphic
  c.initSprite(SpriteDim)
  discard c.addAnimation("up",    toSeq(0..3),    framerate)
  discard c.addAnimation("down",  toSeq(4..7),    framerate)
  discard c.addAnimation("left",  toSeq(8..11),   framerate)
  discard c.addAnimation("right", toSeq(12..15),  framerate)
  discard c.addAnimation("death", [0, 4, 8, 12],  framerate)
  c.collider = c.newBoxCollider(SpriteDim / 2 - SpriteOffset, SpriteDim * 0.9)
  c.center = SpriteOffset
  c.map = map
  c.placeTo(mapPos)


proc newCreature*(graphic: TextureGraphic, mapPos: MapPos, map: Map): Creature =
  new result
  init result, graphic, mapPos, map


proc dirAvailable*(c: Creature, dir: Direction): bool =
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
    mapMov: MapPos
  case dir:
  of dStay:
    return
  of dUp:
    anim = "up"
    mov = (0.0, -c.sprite.dim.h.float)
    mapMov = (0, -1)
  of dDown:
    anim = "down"
    mov = (0.0, c.sprite.dim.h.float)
    mapMov = (0, 1)
  of dLeft:
    anim = "left"
    mov = (-c.sprite.dim.w.float, 0.0)
    mapMov = (-1, 0)
  of dRight:
    anim = "right"
    mov = (c.sprite.dim.w.float, 0.0)
    mapMov = (1, 0)

  if c.tween == nil or not c.tween.playing:
    # fix pos
    c.pos = c.mapPos.toCoord
    let
      newPos = c.pos + mov
      newMapPos = (c.mapPos.x + mapMov.x, c.mapPos.y + mapMov.y)

    c.play(anim, 1)
    c.tween = newTween[Creature,Coord](
      c,
      proc(t: Creature): Coord = t.pos,
      proc(t: Creature, val: Coord) = t.pos = val
    )
    c.tween.setup(c.pos, newPos, speed, 0)
    c.tween.play()
    c.mapPos = newMapPos
    c.prevDirection = dir


proc updateCreature*(c: Creature, elapsed: float) =
  c.updateEntity elapsed
  if c.tween != nil:
    c.tween.update elapsed


method update*(c: Creature, elapsed: float) =
  c.updateCreature elapsed

