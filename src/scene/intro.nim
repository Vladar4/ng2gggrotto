import
  nimgame2 / [
    assets,
    nimgame,
    entity,
    scene,
    settings,
    tween,
    types,
  ],
  ../data,
  title


type
  IntroScene = ref object of Scene
    player, logo: Entity
    tween: Tween[Entity,Coord]


template introSpeed(): float =
  DefaultSpeed / 2


proc init*(scene: IntroScene) =
  init Scene(scene)
  scene.player = newEntity()
  scene.player.graphic = gfxData["player"]
  scene.player.initSprite(SpriteDim)
  discard scene.player.addAnimation("left", toSeq(8..11), introSpeed / 4)
  discard scene.player.addAnimation("down", toSeq(4..7), introSpeed / 4)
  scene.add scene.player
  scene.tween = newTween[Entity,Coord](
    scene.player,
    proc(t: Entity): Coord = t.pos,
    proc(t: Entity, val: Coord) = t.pos = val)
  scene.logo = newEntity()
  scene.logo.graphic = gfxData["ng2logo"]
  scene.logo.parent = scene.player
  scene.logo.centrify(HAlign.left, VAlign.bottom)
  scene.logo.pos += (23.0, -1 + 1.6 * scene.player.sprite.dim.h.float)
  scene.add scene.logo


proc free*(scene: IntroScene) =
  discard


method show*(scene: IntroScene) =
  scene.player.pos = (
    game.size.w.float + scene.player.sprite.dim.w.float,
    game.size.h.float - 1.6 * scene.player.sprite.dim.h.float)
  scene.tween.setup(
    scene.player.pos,
    scene.player.pos - (220.0, 0.0),
    introSpeed * 220.0 / scene.player.sprite.dim.w.float, 0)
  scene.tween.play()
  scene.player.play("left", -1)


proc newIntroScene*(): IntroScene =
  new result, free
  init result


method event*(scene: IntroScene, e: Event) =
  if e.kind in {KeyDown, MouseButtonDown}:
    game.scene = titleScene


from math import round

method update*(scene: IntroScene, elapsed: float) =
  scene.updateScene elapsed
  scene.tween.update elapsed
  if round(scene.player.pos.x) == scene.tween.finish.x:
    scene.logo.pos = scene.logo.absPos
    scene.logo.parent = nil
    scene.tween.setup(
      scene.player.pos,
      scene.player.pos + (0.0, 40.0),
      introSpeed * 40.0 / scene.player.sprite.dim.h.float, 0)
    scene.tween.play()
    scene.player.play("down", -1)

  if scene.player.pos.y >= game.size.h.float:
    game.scene = titleScene

