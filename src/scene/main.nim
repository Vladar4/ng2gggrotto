import
  nimgame2 / [
    assets,
    nimgame,
    entity,
    scene,
    settings,
    types,
  ],
  ../creature,
  ../data,
  ../player,
  ../map


const
  MapRows = 2
  MapCols = 2
  MapLayer = -100
  MapSwitchCooldown = 1.0


type
  MainScene = ref object of Scene
    mapGrid: array[MapRows, array[MapCols, Map]]
    mapIdx: tuple[x, y: int]
    player: Player
    mapSwitchCooldown: float


template currentMap(scene: MainScene): Map =
  scene.mapGrid[scene.mapIdx.y][scene.mapIdx.x]


template `currentMap=`(scene: MainScene, idx: tuple[x, y: int]) =
  scene.mapIdx = idx


proc init*(scene: MainScene) =
  init Scene(scene)
  scene.mapSwitchCooldown = 0.0
  # maps
  for y in 0..<MapRows:
    for x in 0..<MapCols:
      scene.mapGrid[y][x] = newMap()
      scene.mapGrid[y][x].layer = MapLayer
  scene.mapIdx = (0, 0)
  # player
  scene.player = newPlayer(
    (MapTileWidth div 2 + 1, MapTileHeight div 2 + 1), scene.currentMap)

  # add to scene
  scene.add scene.player
  scene.add scene.currentMap


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


proc changeMap(scene: MainScene, idx: tuple[x, y: int]) =
  discard scene.del scene.currentMap
  scene.mapIdx = idx
  scene.currentMap = idx
  scene.player.map = scene.currentMap
  scene.add scene.currentMap
  scene.mapSwitchCooldown = MapSwitchCooldown


template goUp(scene: MainScene) =
  let idx = scene.mapIdx
  scene.changeMap if idx.y > 0: (idx.x, idx.y - 1)
                  else: (idx.x, MapRows - 1)
  scene.player.map = scene.currentMap
  scene.player.placeTo(scene.currentMap.exitD)


template goDown(scene: MainScene) =
  let idx = scene.mapIdx
  scene.changeMap if idx.y < (MapRows - 1): (idx.x, idx.y + 1)
                  else: (idx.x, 0)
  scene.player.map = scene.currentMap
  scene.player.placeTo(scene.currentMap.exitU)


template goLeft(scene: MainScene) =
  let idx = scene.mapIdx
  scene.changeMap if idx.x > 0: (idx.x - 1, idx.y)
                  else: (MapCols - 1, idx.y)
  scene.player.map = scene.currentMap
  scene.player.placeTo(scene.currentMap.exitR)


template goRight(scene: MainScene) =
  let idx = scene.mapIdx
  scene.changeMap if idx.x < (MapCols - 1): (idx.x + 1, idx.y)
                  else: (0, idx.y)
  scene.player.map = scene.currentMap
  scene.player.placeTo(scene.currentMap.exitL)


method update*(scene: MainScene, elapsed: float) =
  scene.updateScene elapsed
  if scene.mapSwitchCooldown <= 0.0:
    if scene.player.pos.y <= 1.0:
      scene.goUp()
    elif scene.player.pos.y >= (GameHeight -
                                scene.player.sprite.dim.h.float + 1.0):
      scene.goDown()
    elif scene.player.pos.x <= 1.0:
      scene.goLeft()
    elif scene.player.pos.x >= (GameWidth -
                                scene.player.sprite.dim.w.float + 1.0):
      scene.goRight()
  else:
    scene.mapSwitchCooldown -= elapsed

