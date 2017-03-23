import
  nimgame2 / [
    assets,
    audio,
    nimgame,
    entity,
    font,
    input,
    scene,
    settings,
    textfield,
    textgraphic,
    types,
  ],
  ../data,
  ../score


type
  HiscoreScene* = ref object of Scene
    headerText: TextGraphic
    victory*: bool
    input*: Entity
    index*: int
    winscreen, losescreen: Entity


proc init*(scene: HiscoreScene) =
  init Scene(scene)
  # title
  let header = newEntity()
  scene.headerText = newTextGraphic defaultFont
  scene.headerText.lines = ["ENTER YOUR NAME"]
  scene.headerText.align = TextAlign.center
  header.graphic = scene.headerText
  header.centrify(ver = VAlign.top)
  header.pos = (
    game.size.w / 2, game.size.h / 2 - defaultFont.charH.float * 2.0)
  scene.add header
  # input
  let
    textField = newTextField(defaultFont)
  textField.limit = NameLength
  scene.input = newEntity()
  scene.input.graphic = textField
  scene.input.centrify()
  scene.input.pos = game.size / 2
  scene.add scene.input
  # screens
  let screenpos = (game.size.w / 2, game.size.h / 2 + 32)
  scene.winscreen = newEntity()
  scene.winscreen.graphic = gfxData["winscreen"]
  scene.winscreen.centrify(ver = VAlign.top)
  scene.winscreen.pos = screenpos
  scene.winscreen.visible = false
  scene.add scene.winscreen
  scene.losescreen = newEntity()
  scene.losescreen.graphic = gfxData["losescreen"]
  scene.losescreen.centrify(ver = VAlign.top)
  scene.losescreen.pos = screenpos
  scene.losescreen.visible = false
  scene.add scene.losescreen


method show*(scene: HiscoreScene) =
  scene.winscreen.visible = scene.victory
  scene.losescreen.visible = not scene.victory
  TextField(scene.input.graphic).activate()
  if scene.victory:
    discard sfxData["victory"].play()


proc free*(scene: HiscoreScene) =
  free scene.headerText
  freeData()


proc newHiscoreScene*(): HiscoreScene =
  new result, free
  init result


method event(scene: HiscoreScene, event: Event) =
  scene.eventScene event
  if event.kind == KeyDown:
    case event.key.keysym.sym:
    of K_F11:
      showInfo = not showInfo
    else:
      discard

    let text = TextField(scene.input.graphic)
    case event.key.keysym.scancode:
    of ScancodeBackspace:
      text.bs()
      scene.input.centrify()
    of ScancodeDelete:
      text.del()
      scene.input.centrify()
    of ScancodeLeft:
      text.left()
    of ScancodeRight:
      text.right()
    of ScancodeHome:
      text.toFirst()
    of ScancodeEnd:
      text.toLast()
    of ScancodeReturn:
      text.deactivate()
      hiscores[scene.index].name = text.text.toName
      hiscores[scene.index].score = playerScore.uint
      writeHiscores()
      game.scene = titleScene
    else:
      discard
  elif event.kind == TextInput:
    TextField(scene.input.graphic).add $event.text.text
    scene.input.centrify()

