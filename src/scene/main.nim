import
  random,
  nimgame2 / [
    assets,
    nimgame,
    entity,
    scene,
    settings,
    types,
    utils,
  ],
  ../creature,
  ../data,
  ../enemy,
  ../item,
  ../player,
  ../map


const
  MapRows = 2
  MapCols = 2
  MapLayer = -100
  ItemLayer = 100
  PlayerLayer = 200
  EnemyLayer = 300
  InterfaceLayer = 1000
  MapSwitchCooldown = 1.0


type
  MainScene = ref object of Scene
    mapGrid: array[MapRows, array[MapCols, Map]]
    itemGrid: array[MapRows, array[MapCols, seq[tuple[kind: ItemKind, pos: MapPos]]]]
    mapIdx: tuple[x, y: int]
    player: Player
    mapSwitchCooldown: float
    pause: Entity


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
      # items
      let
        itemList = [ikSmall, ikBig]
        occupied: seq[MapPos] = @[]
      scene.itemGrid[y][x] = @[]
      for i in 1..ItemsAmount:
        scene.itemGrid[y][x].add((
          itemList[randomWeighted([75, 25])],
          random(scene.mapGrid[y][x].spawnPoints, occupied)))
      for i in 1..random(2..4):
        scene.itemGrid[y][x].add((
          ikSpawn,
          random(scene.mapGrid[y][x].spawnPoints, occupied)))
  scene.mapIdx = (0, 0)
  scene.add scene.currentMap
  # player
  scene.player = newPlayer(
    (MapTileWidth div 2 + 1, MapTileHeight div 2 + 1), scene.currentMap)
  scene.player.layer = PlayerLayer
  scene.add scene.player
  # enemies
  for i in 0..3:
    let e = newEnemy(1, random scene.currentMap.spawnPoints, scene.currentMap)
    scene.add e
  # items
  for i in scene.itemGrid[scene.mapIdx.y][scene.mapIdx.x]:
    scene.add newItem(i.kind, i.pos)
  # pause
  scene.pause = newEntity()
  scene.pause.graphic = gfxData["pause"]
  scene.pause.centrify()
  scene.pause.pos = (GameWidth / 2, GameHeight / 2)
  scene.pause.layer = InterfaceLayer
  scene.pause.visible = false
  scene.add scene.pause


proc free*(scene: MainScene) =
  discard


proc newMainScene*(): MainScene =
  new result, free
  init result


method event*(scene: MainScene, event: Event) =
  scene.eventScene event
  if event.kind == KeyDown:
    case event.key.keysym.sym:
    of K_Escape, K_P:
      gamePaused = not gamePaused
      scene.pause.visible = gamePaused
    of K_F10:
      colliderOutline = not colliderOutline
    of K_F11:
      showInfo = not showInfo
    else:
      discard


proc changeMap(scene: MainScene, idx: tuple[x, y: int]) =
  discard scene.del scene.currentMap
  scene.del "enemy"
  scene.del "item"
  scene.mapIdx = idx
  scene.currentMap = idx
  scene.player.map = scene.currentMap
  for i in 0..3:
    let e = newEnemy(1, random scene.currentMap.spawnPoints, scene.currentMap)
    scene.add e
  scene.add scene.currentMap
  scene.mapSwitchCooldown = MapSwitchCooldown
  # items
  for i in scene.itemGrid[scene.mapIdx.y][scene.mapIdx.x]:
    scene.add newItem(i.kind, i.pos)


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

