import
  nimgame2 / [
    assets,
    input,
  ],
  creature,
  data,
  map


type
  Enemy* = ref object of Creature
    id*: int


proc init*(e: Enemy, id: int, mapPos: MapPos, map: Map) =
  Creature(e).init gfxData["enemy" & $id], mapPos, map
  e.id = id


proc newEnemy*(id: int, mapPos: MapPos, map: Map): Enemy =
  new result
  init result, id, mapPos, map


method update*(e: Enemy, elapsed: float) =
  e.updateCreature elapsed
  if e.prevDirection != dStay and e.dirAvailable(e.prevDirection):
    e.move(e.prevDirection)
  elif e.dirAvailable(dUp): e.move(dUp)
  elif e.dirAvailable(dDown): e.move(dDown)
  elif e.dirAvailable(dLeft): e.move(dLeft)
  elif e.dirAvailable(dRight): e.move(dRight)

