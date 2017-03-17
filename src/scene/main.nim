import
  nimgame2 / [
    assets,
    nimgame,
    entity,
    scene,
    settings,
    types,
  ],
  ../data,
  ../creature,
  ../map


type
  MainScene = ref object of Scene
    map: Map
    player: Creature


proc init*(scene: MainScene) =
  init Scene(scene)
  # map
  scene.map = newMap()
  # player
  scene.player = newCreature(gfxData["player"],
                             (MapTileWidth div 2 + 1, MapTileHeight div 2 + 1),
                             scene.map)
  scene.player.control = Control.player

  # add to scene
  scene.add scene.player
  scene.add scene.map



proc free*(scene: MainScene) =
  discard


proc newMainScene*(): MainScene =
  new result, free
  init result


method event*(scene: MainScene, event: Event) =
  scene.eventScene event
  if event.kind == KeyDown:
    case event.key.keysym.sym:
    of K_F11:
      showInfo = not showInfo
    else:
      discard

