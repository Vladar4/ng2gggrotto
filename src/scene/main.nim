import
  nimgame2 / [
    nimgame,
    entity,
    scene,
    settings,
    types,
  ],
  ../map


type
  MainScene = ref object of Scene
    map: Map


proc init*(scene: MainScene) =
  init Scene(scene)
  scene.map = newMap()
  scene.add scene.map


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

