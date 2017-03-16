import
  nimgame2 / [
    nimgame,
    entity,
    scene,
    settings,
    types
  ]


type
  MainScene = ref object of Scene


proc init*(scene: MainScene) =
  init Scene(scene)


proc free*(scene: MainScene) =
  discard


proc newMainScene*(): MainScene =
  new result, free
  init result


