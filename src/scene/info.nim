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
  main


type
  InfoScene = ref object of Scene
    infoText: TextGraphic
    btnBack: MenuButton


proc init*(scene: InfoScene) =
  init Scene(scene)

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
    center = (game.size.w.float / 3.25, game.size.h / 2 - 32)
    step = (0.0, 64.0)
    width = 6

  scene.btnBack = newMenuButton(center + step * 3.0, width,
    proc(btn: MenuButton) {.locks:0.} = game.scene = titleScene,
    "BACK")
  scene.btnBack.centrify()
  scene.add scene.btnBack

  # title
  let title = newEntity()
  title.graphic = gfxData["titlescreen"]
  title.centrify(ver = VAlign.top)
  title.pos = (game.size.w / 2, 0.0)
  scene.add title



proc free*(scene: InfoScene) =
  free scene.infoText
  free scene.btnBack
  freeData()


proc newInfoScene*(): InfoScene =
  new result, free
  init result


method show*(scene: InfoScene) =
  discard


method event*(scene: InfoScene, event: Event) =
  scene.eventScene event
  if event.kind == KeyDown:
    case event.key.keysym.sym:
    of K_F10:
      colliderOutline = not colliderOutline
    of K_F11:
      showInfo = not showInfo
    else:
      discard

