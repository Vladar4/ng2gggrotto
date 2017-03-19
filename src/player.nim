import
  nimgame2 / [
    assets,
    entity,
    input,
    tween,
  ],
  creature,
  data,
  map


type
  Player* = ref object of Creature
    killed*: bool


proc init*(p: Player, mapPos: MapPos, map: Map) =
  Creature(p).init gfxData["player"], mapPos, map
  p.tags.add "player"
  p.collider.tags.add "enemy"


proc newPlayer*(mapPos: MapPos, map: Map): Player =
  new result
  init result, mapPos, map


proc kill*(p: Player) =
  p.killed = true
  if p.tween != nil:
    p.tween.stop()
  p.play("death", 2, true)


method update*(p: Player, elapsed: float) =
  p.updateCreature elapsed
  if not p.killed:
    if moveUp.down and p.dirAvailable(dUp): p.move(dUp)
    elif moveDown.down and p.dirAvailable(dDown): p.move(dDown)
    elif moveLeft.down and p.dirAvailable(dLeft): p.move(dLeft)
    elif moveRight.down and p.dirAvailable(dRight): p.move(dRight)
    elif p.dirAvailable(p.prevDirection): p.move(p.prevDirection)


method onCollide*(p: Player, target: Entity) =
  if not p.killed:
    if "enemy" in target.tags:
      p.kill()

