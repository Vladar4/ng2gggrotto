import
  nimgame2 / [
    assets,
    nimgame,
    entity,
    scene,
    settings,
    textgraphic,
    texturegraphic,
    types,
  ],
  ../menubutton,
  ../data,
  ../score,
  main


type
  TitleScene = ref object of Scene
    scoreText, infoText: TextGraphic
    scoreboard: Entity
    btnPlay, btnConfig, btnInfo, btnExit: MenuButton
    exit: bool


proc init*(scene: TitleScene) =
  init Scene(scene)
  scene.exit = false

  # scoreboard
  initHiscores()
  scene.scoreText = newTextGraphic defaultFont
  scene.scoreboard = newEntity()
  scene.scoreboard.graphic = scene.scoreText
  scene.scoreboard.pos = (16, 212)
  scene.add scene.scoreboard

  # info
  scene.infoText = newTextGraphic bonusFont
  scene.infoText.lines = [GameInfo]
  let info = newEntity()
  info.graphic = scene.infoText
  info.centrify(hor = HAlign.left, ver = VAlign.bottom)
  info.pos = (4.0, game.size.h.float - 4.0)
  scene.add info

  # buttons
  let
    center = (game.size.w / 2, game.size.h / 2 - 32)
    step = (0.0, 64.0)
    width = 6

  scene.btnPlay = newMenuButton(center, width,
    proc(btn: MenuButton) {.locks:0.} = game.scene = newMainScene(),
    "PLAY")
  scene.btnPlay.centrify()
  scene.add scene.btnPlay

  scene.btnConfig = newMenuButton(center + step, width,
    proc(btn: MenuButton) {.locks:0.} = game.scene = configScene,
    "CONFIG")
  scene.btnConfig.centrify()
  scene.add scene.btnConfig

  scene.btnInfo = newMenuButton(center + step * 2.0, width,
    proc(btn: MenuButton) {.locks:0.} = game.scene = infoScene,
    "INFO")
  scene.btnInfo.centrify()
  scene.add scene.btnInfo

  scene.btnExit = newMenuButton(center + step * 3.0, width,
    proc(btn: MenuButton) {.locks:0.} = scene.exit = true,
    "EXIT")
  scene.btnExit.centrify()
  scene.add scene.btnExit

  # title
  let title = newEntity()
  title.graphic = gfxData["titlescreen"]
  title.centrify(ver = VAlign.top)
  title.pos = (game.size.w / 2, 0.0)
  scene.add title



proc free*(scene: TitleScene) =
  free scene.infoText
  free scene.scoreText
  free scene.btnPlay
  free scene.btnConfig
  free scene.btnInfo
  free scene.btnExit
  freeData()


proc newTitleScene*(): TitleScene =
  new result, free
  init result


method show*(scene: TitleScene) =
  initHiscores()
  scene.scoreText.lines = [
    "        HISCORES        ",
    hiscores[0].name.toString & " " & $hiscores[0].score,
    hiscores[1].name.toString & " " & $hiscores[1].score,
    hiscores[2].name.toString & " " & $hiscores[2].score,
    hiscores[3].name.toString & " " & $hiscores[3].score,
    hiscores[4].name.toString & " " & $hiscores[4].score,
    hiscores[5].name.toString & " " & $hiscores[5].score,
    hiscores[6].name.toString & " " & $hiscores[6].score,
    hiscores[7].name.toString & " " & $hiscores[7].score,
    hiscores[8].name.toString & " " & $hiscores[8].score,
    hiscores[9].name.toString & " " & $hiscores[9].score
  ]


method event*(scene: TitleScene, event: Event) =
  scene.eventScene event
  if event.kind == KeyDown:
    case event.key.keysym.sym:
    of K_F10:
      colliderOutline = not colliderOutline
    of K_F11:
      showInfo = not showInfo
    else:
      discard


method update*(scene: TitleScene, elapsed: float) =
  scene.updateScene elapsed
  if scene.exit:
    gameRunning = false

