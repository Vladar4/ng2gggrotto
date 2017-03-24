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
    text, infoText: TextGraphic
    btnBack: MenuButton


proc init*(scene: InfoScene) =
  init Scene(scene)

  # pics
  let
    egg = newEntity()
    enemy = newEntity()
    follower = newEntity()
  egg.graphic = gfxData["egg"]
  egg.centrify(ver = VAlign.top)
  enemy.graphic = gfxData["enemy1"]
  enemy.initSprite(SpriteDim)
  discard enemy.addAnimation("a", toSeq(4..7))
  enemy.play("a", -1)
  enemy.centrify(ver = VAlign.top)
  follower.graphic = gfxData["follower"]
  follower.initSprite(SpriteDim)
  discard follower.addAnimation("a", toSeq(4..7))
  follower.play("a", -1)
  follower.centrify(ver = VAlign.top)
  # y: 224, 256, 288, 320, 352, 384, 416, 448, 480, 512
  egg.pos = (234.0, 288.0)
  enemy.pos = (186.0, 320.0)
  follower.pos = (154.0, 384.0)
  scene.add egg
  scene.add enemy
  scene.add follower

  # text
  scene.text = newTextGraphic defaultFont
  scene.text.lines = [
    "            HOW TO PLAY",
    "To win the game you must collect",
    "all the eggs   , while evading",
    "the yetis   .",
    "Each egg gives you one more",
    "partner   , increasing your",
    "score multiplier.",
    "The more partners you have,",
    "the faster you are."
  ]
  let t = newEntity()
  t.graphic = scene.text
  t.pos = (16.0, 212.0)
  scene.add t

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

  scene.btnBack = newMenuButton(center + step * 4.25, width,
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
  free scene.text
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
    of K_Escape:
      game.scene = titleScene
    else:
      discard

