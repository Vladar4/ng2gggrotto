import
  nimgame2 / [
    assets,
    entity,
    tween,
    types,
  ],
  creature,
  data,
  map


type
  Follower* = ref object of Creature
    target*: Creature
    killed*: bool


proc init*(f: Follower, target: Creature, mapPos: MapPos, map: Map) =
  Creature(f).init gfxData["follower"], mapPos, map
  f.tags.add "follower"
  f.killed = false
  f.target = target
  f.collider.tags.add("enemy")


proc newFollower*(target: Creature, mapPos: MapPos, map: Map): Follower =
  new result
  init result, target, mapPos, map


proc kill*(f: Follower) =
  f.killed = true
  if f.tween != nil:
    f.tween.stop()
  f.play("death", 2, true)
  dec scoreMultiplier


method update*(f: Follower, elapsed: float) =
  f.updateCreature elapsed
  if not f.killed:
    let
      w = float(SpriteDim.w) / 1.1
      h = float(SpriteDim.h) / 1.1
    if (f.target.pos.y < (f.pos.y - h)) and f.dirAvailable(dUp):
      f.move(dUp)
    elif (f.target.pos.y > (f.pos.y + h)) and f.dirAvailable(dDown):
      f.move(dDown)
    elif (f.target.pos.x < (f.pos.x - w)) and f.dirAvailable(dLeft):
      f.move(dLeft)
    elif (f.target.pos.x > (f.pos.x + w)) and f.dirAvailable(dRight):
      f.move(dRight)


method onCollide*(f: Follower, target: Entity) =
  if not f.killed:
    if "enemy" in target.tags:
      f.kill()

