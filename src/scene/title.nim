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
  ../data,
  ../score,
  main


type
  TitleScene = ref object of Scene
    scoreText, infoText: TextGraphic
    scoreboard: Entity


proc init*(scene: TitleScene) =
  init Scene(scene)

  # title
  let title = newEntity()
  title.graphic = gfxData["titlescreen"]
  title.centrify(ver = VAlign.top)
  title.pos = (game.size.w / 2, 0.0)
  scene.add title

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


proc free*(scene: TitleScene) =
  free scene.infoText
  free scene.scoreText
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
    of K_F11:
      showInfo = not showInfo
    of K_Escape:
      gameRunning = false
    else:
      mainScene = newMainScene()
      game.scene = mainScene

