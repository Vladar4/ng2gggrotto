import
  nimgame2 / [
    assets,
    input,
  ],
  creature,
  data,
  map


type
  Player* = ref object of Creature


proc init*(p: Player, mapPos: MapPos, map: Map) =
  Creature(p).init gfxData["player"], mapPos, map
  p.tags.add "player"


proc newPlayer*(mapPos: MapPos, map: Map): Player =
  new result
  init result, mapPos, map


method update*(p: Player, elapsed: float) =
  p.updateCreature elapsed
  if moveUp.down and p.dirAvailable(dUp): p.move(dUp)
  elif moveDown.down and p.dirAvailable(dDown): p.move(dDown)
  elif moveLeft.down and p.dirAvailable(dLeft): p.move(dLeft)
  elif moveRight.down and p.dirAvailable(dRight): p.move(dRight)
  elif p.dirAvailable(p.prevDirection): p.move(p.prevDirection)

