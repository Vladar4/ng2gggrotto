import
  random,
  nimgame2 / [
    assets,
  ],
  creature,
  data,
  map


type
  Enemy* = ref object of Creature
    id*: int


proc init*(e: Enemy, id: int, mapPos: MapPos, map: Map) =
  Creature(e).init gfxData["enemy" & $id], mapPos, map
  e.tags.add "enemy"
  e.id = id


proc newEnemy*(id: int, mapPos: MapPos, map: Map): Enemy =
  new result
  init result, id, mapPos, map


proc perpendiculars(dir: Direction): tuple[a, b: Direction] =
  return case dir:
  of dUp, dDown: (dLeft, dRight)
  of dLeft, dRight: (dUp, dDown)
  else: (dStay, dStay)


method update*(e: Enemy, elapsed: float) =
  e.updateCreature elapsed
  let perp = perpendiculars(e.prevDirection)
  if  e.prevDirection != dStay and
      e.dirAvailable(e.prevDirection) and
      not e.dirAvailable(perp.a) and
      not e.dirAvailable(perp.b):
    e.move(e.prevDirection)
  else:
    var choice = @[dUp, dDown, dLeft, dRight]
    shuffle choice

    for dir in choice:
      if e.dirAvailable dir:
        e.move dir
        break

