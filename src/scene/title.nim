import
  nimgame2 / [
    nimgame,
    entity,
    scene,
    settings,
    types
  ],
  ../data,
  main


type
  TitleScene = ref object of Scene


proc init*(scene: TitleScene) =
  init Scene(scene)
  mainScene = newMainScene()
  game.scene = mainScene #TODO remove


proc free*(scene: TitleScene) =
  discard


proc newTitleScene*(): TitleScene =
  new result, free
  init result


