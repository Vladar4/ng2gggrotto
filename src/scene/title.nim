import
  nimgame2 / [
    nimgame,
    entity,
    scene,
    settings,
    textgraphic,
    types,
  ],
  ../data,
  main


type
  TitleScene = ref object of Scene
    titleText: TextGraphic


proc init*(scene: TitleScene) =
  init Scene(scene)
  # Title
  let title = newEntity()
  scene.titleText = newTextGraphic defaultFont
  scene.titleText.lines = [
    GameTitle,
    "________________________",
    "",
    " press any key to start "]
  scene.titleText.align = TextAlign.center
  title.graphic = scene.titleText
  title.centrify(ver = VAlign.top)
  title.pos = (game.size.w / 2, 20.0)
  scene.add title


proc free*(scene: TitleScene) =
  free scene.titleText
  freeData()


proc newTitleScene*(): TitleScene =
  new result, free
  init result


method event(scene: TitleScene, event: Event) =
  scene.eventScene event
  if event.kind == KeyDown:
    case event.key.keysym.sym:
    of K_F11:
      showInfo = not showInfo
    else:
      game.scene = mainScene

