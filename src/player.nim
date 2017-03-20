import
  nimgame2 / [
    assets,
    audio,
    entity,
    input,
    tween,
  ],
  creature,
  data,
  map


type
  Player* = ref object of Creature
    lastPressed*: Direction
    pressTime*: float
    killed*: bool


template pressTimeLimit(): float =
  speed


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
  if not sfxData["death_1"].playing:
    discard sfxData["death_1"].play()


method update*(p: Player, elapsed: float) =
  p.updateCreature elapsed
  if not p.killed:
    if moveUp.down:
      p.lastPressed = dUp
      p.pressTime = pressTimeLimit
    elif moveDown.down:
      p.lastPressed = dDown
      p.pressTime = pressTimeLimit
    elif moveLeft.down:
      p.lastPressed = dLeft
      p.pressTime = pressTimeLimit
    elif moveRight.down:
      p.lastPressed = dRight
      p.pressTime = pressTimeLimit
    else:
      if p.pressTime > 0.0:
        p.pressTime -= elapsed
        if p.pressTime < 0.0:
          p.pressTime = 0.0
      if p.pressTime == 0.0:
        p.lastPressed = dStay

    if (p.lastPressed != dStay) and p.dirAvailable(p.lastPressed):
      p.move(p.lastPressed)
    elif p.dirAvailable(p.prevDirection):
      p.move(p.prevDirection)


method onCollide*(p: Player, target: Entity) =
  if not p.killed:
    if "enemy" in target.tags:
      p.kill()

