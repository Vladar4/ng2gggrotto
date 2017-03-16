import
  nimgame2 / [
    nimgame,
    entity,
    scene,
    settings,
    types,
  ],
  ../data,
  title


type
  IntroScene = ref object of Scene


proc init*(scene: IntroScene) =
  init Scene(scene)


proc free*(scene: IntroScene) =
  discard


proc newIntroScene*(): IntroScene =
  new result, free
  init result


method update*(scene: IntroScene, elapsed: float) =
  scene.updateScene elapsed
  game.scene = titleScene

