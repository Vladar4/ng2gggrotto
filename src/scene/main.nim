import
  random,
  nimgame2 / [
    assets,
    nimgame,
    entity,
    scene,
    settings,
    textgraphic,
    tween,
    types,
    utils,
  ],
  ../creature,
  ../data,
  ../enemy,
  ../follower,
  ../item,
  ../player,
  ../map


const
  MapRows = 2
  MapCols = 2
  MapLayer = -100
  FollowerLayer = 200
  PlayerLayer = 300
  EnemyLayer = 500
  InterfaceLayer = 1000
  MapSwitchCooldown = 1.0


type
  MainScene = ref object of Scene
    mapGrid: array[MapRows, array[MapCols, Map]]
    itemGrid: array[MapRows, array[MapCols, seq[tuple[kind: ItemKind, pos: MapPos]]]]
    mapIdx: tuple[x, y: int]
    currentMap: Map
    train: seq[Creature]
    mapSwitchCooldown: float
    livesText, scoreText, goalText: Entity
    pause: Entity


proc switchMap(scene: MainScene, idx: tuple[x, y: int]) =
  scene.mapIdx = idx
  scene.currentMap = scene.mapGrid[idx.y][idx.x]


template player(scene: MainScene): Player =
  Player(scene.train[0])


proc init*(scene: MainScene) =
  init Scene(scene)
  scene.mapSwitchCooldown = 0.0
  # reset data
  playerLives = StartPlayerLives
  playerScore = 0
  playerGoal = 0
  playerTargetGoal = 0
  # maps
  for y in 0..<MapRows:
    for x in 0..<MapCols:
      var occupied: seq[MapPos] = @[]
      scene.mapGrid[y][x] = newMap()
      scene.mapGrid[y][x].layer = MapLayer
      # items
      let itemList = [ikSmall, ikBig]
      scene.itemGrid[y][x] = @[]
      for i in 1..ItemsAmount:
        let newPos = random(scene.mapGrid[y][x].spawnPoints, occupied)
        scene.itemGrid[y][x].add((itemList[randomWeighted([75, 25])], newPos))
        occupied.add newPos
      for i in 1..GoalsAmount:
        let newPos = random(scene.mapGrid[y][x].spawnPoints, occupied)
        scene.itemGrid[y][x].add((ikSpawn, newPos))
        occupied.add newPos
        inc playerTargetGoal
  scene.switchMap((0, 0))
  scene.add scene.currentMap
  # player
  scene.train = @[]
  scene.train.add newPlayer(
    (MapTileWidth div 2 + 1, MapTileHeight div 2 + 1), scene.currentMap)
  scene.player.layer = PlayerLayer
  scene.add scene.player
  # enemies
  for i in 1..EnemiesAmount:
    let e = newEnemy(1, random scene.currentMap.spawnPoints, scene.currentMap)
    e.layer = EnemyLayer
    scene.add e
  # items
  for i in scene.itemGrid[scene.mapIdx.y][scene.mapIdx.x]:
    scene.add newItem(i.kind, i.pos)
  # interface: lives
  scene.livesText = newEntity()
  scene.livesText.graphic = newTextGraphic defaultFont
  TextGraphic(scene.livesText.graphic).lines = ["LIVES: " & $playerLives]
  scene.livesText.pos = (8.0, 0.0)
  scene.livesText.layer = InterfaceLayer
  scene.add scene.livesText
  # interface: score
  scene.scoreText = newEntity()
  scene.scoreText.graphic = newTextGraphic defaultFont
  TextGraphic(scene.scoreText.graphic).lines = ["SCORE: " & $playerScore]
  scene.scoreText.pos = (8.0, 32.0)
  scene.scoreText.layer = InterfaceLayer
  scene.add scene.scoreText
  # interface: goal
  scene.goalText = newEntity()
  scene.goalText.graphic = newTextGraphic defaultFont
  TextGraphic(scene.goalText.graphic).lines = [
    "EGGS: " & $playerGoal & "/" & $playerTargetGoal]
  scene.goalText.pos = (160.0, 0.0)
  scene.goalText.layer = InterfaceLayer
  scene.add scene.goalText
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
  let
    x = scene.mapIdx.x
    y = scene.mapIdx.y
  # clean up items
  scene.itemGrid[y][x].setLen 0
  for i in scene.findAll "item":
    let item = Item(i)
    if not item.dead:
      scene.itemGrid[y][x].add((item.kind, item.mapPos))
  scene.del "item"
  discard scene.del scene.currentMap
  scene.switchMap idx
  # train
  for t in scene.train:
    t.map = scene.currentMap
  # enemies
  scene.del "enemy"
  for i in 1..EnemiesAmount:
    let e = newEnemy(1, random scene.currentMap.spawnPoints, scene.currentMap)
    e.layer = EnemyLayer
    scene.add e
  scene.add scene.currentMap
  scene.mapSwitchCooldown = MapSwitchCooldown
  # items
  for i in scene.itemGrid[scene.mapIdx.y][scene.mapIdx.x]:
    scene.add newItem(i.kind, i.pos)
  GC_fullCollect()


template goUp(scene: MainScene) =
  let idx = scene.mapIdx
  scene.changeMap if idx.y > 0: (idx.x, idx.y - 1)
                  else: (idx.x, MapRows - 1)
  scene.train[0].placeTo(scene.currentMap.exitD)
  for i in 1..scene.train.high:
    if scene.train[i].tween != nil:
      scene.train[i].tween.stop()
    scene.train[i].placeTo(scene.currentMap.exitD)


template goDown(scene: MainScene) =
  let idx = scene.mapIdx
  scene.changeMap if idx.y < (MapRows - 1): (idx.x, idx.y + 1)
                  else: (idx.x, 0)
  scene.train[0].placeTo(scene.currentMap.exitU)
  for i in 1..scene.train.high:
    if scene.train[i].tween != nil:
      scene.train[i].tween.stop()
    scene.train[i].placeTo(scene.currentMap.exitU)


template goLeft(scene: MainScene) =
  let idx = scene.mapIdx
  scene.changeMap if idx.x > 0: (idx.x - 1, idx.y)
                  else: (MapCols - 1, idx.y)
  scene.train[0].placeTo(scene.currentMap.exitR)
  for i in 1..scene.train.high:
    if scene.train[i].tween != nil:
      scene.train[i].tween.stop()
    scene.train[i].placeTo(scene.currentMap.exitR)


template goRight(scene: MainScene) =
  let idx = scene.mapIdx
  scene.changeMap if idx.x < (MapCols - 1): (idx.x + 1, idx.y)
                  else: (0, idx.y)
  scene.train[0].placeTo(scene.currentMap.exitL)
  for i in 1..scene.train.high:
    if scene.train[i].tween != nil:
      scene.train[i].tween.stop()
    scene.train[i].placeTo(scene.currentMap.exitL)


method update*(scene: MainScene, elapsed: float) =
  # kill
  var killNext = false
  for i in 1..scene.train.high:
    let f = Follower(scene.train[i])
    if killNext:
      if not f.killed:
        f.kill()
    elif f.killed:
      killNext = true
      if f.dead:
        scene.train.del i
  # spawn
  for i in scene.findAll "spawn":
    if Item(i).spawn:
      scene.train.add newFollower(
        scene.train[^1],
        Item(i).mapPos,
        scene.currentMap)
      scene.train[^1].layer = FollowerLayer
      scene.add scene.train[^1]
  scoreMultiplier = scene.train.len

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

  # interface
  TextGraphic(scene.livesText.graphic).lines = ["LIVES: " & $playerLives]
  TextGraphic(scene.scoreText.graphic).lines = ["SCORE: " & $playerScore]
  TextGraphic(scene.goalText.graphic).lines = [
    "EGGS: " & $playerGoal & "/" & $playerTargetGoal]

