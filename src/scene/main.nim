import
  nimgame2 / [
    nimgame,
    entity,
    scene,
    settings,
    types,
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


method event(scene: MainScene, event: Event) =
  scene.eventScene event
  if event.kind == KeyDown:
    case event.key.keysym.sym:
    of K_F11:
      showInfo = not showInfo
    else:
      discard

