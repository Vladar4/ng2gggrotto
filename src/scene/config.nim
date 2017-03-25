import
  nimgame2 / [
    assets,
    audio,
    entity,
    gui/widget,
    input,
    nimgame,
    scene,
    settings,
    textgraphic,
    texturegraphic,
    types,
  ],
  ../cfg,
  ../data,
  ../menubutton,
  ../volbutton,
  main


type
  ConfigScene = ref object of Scene
    labelSound, labelMusic, infoText: TextGraphic
    btnsSound, btnsMusic: VolGroup
    btnMuteSound, btnMuteMusic, btnBack: MenuButton


proc init*(scene: ConfigScene) =
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
    lblOffset = (64.0, 24.0)

  # btnsSound
  let soundPos: Coord = (219.0, 300.0)
  scene.labelSound = newTextGraphic defaultFont
  scene.labelSound.lines = ["SOUND"]
  let lblS = newEntity()
  lblS.graphic = scene.labelSound
  lblS.centrify(hor = HAlign.right, ver = VAlign.top)
  lblS.pos = soundPos - lblOffset
  scene.add lblS
  for i in 0..<VolSteps:
    scene.btnsSound[i] = newVolButton(
      (soundPos.x + i.float * 32.0, soundPos.y - i.float * 8.0), vkSound, i)
  for i in 0..<VolSteps:
    scene.btnsSound[i].group = scene.btnsSound
    scene.add scene.btnsSound[i]
  scene.btnsSound[^1].toggled = true

  # btnsMusic
  let musicPos: Coord = (219.0, 380.0)
  scene.labelMusic = newTextGraphic defaultFont
  scene.labelMusic.lines = ["MUSIC"]
  let lblM = newEntity()
  lblM.graphic = scene.labelMusic
  lblM.centrify(hor = HAlign.right, ver = VAlign.top)
  lblM.pos = musicPos - lblOffset
  scene.add lblM
  for i in 0..<VolSteps:
    scene.btnsMusic[i] = newVolButton(
      (soundPos.x + i.float * 32.0, musicPos.y - i.float * 8.0), vkMusic, i)
  for i in 0..<VolSteps:
    scene.btnsMusic[i].group = scene.btnsMusic
    scene.add scene.btnsMusic[i]
  scene.btnsMusic[^1].toggled = true

  # mute
  scene.btnMuteSound = newMenuButton(
    (162.0, soundPos.y - 32.0), 2,
    proc(btn: MenuButton) =
      muteSound = btn.toggled
      syncCfg(true),
    "X")
  scene.btnMuteSound.toggle = true
  scene.add scene.btnMuteSound
  scene.btnMuteMusic = newMenuButton(
    (162.0, musicPos.y - 32.0), 2,
    proc(btn: MenuButton) =
      muteMusic = btn.toggled
      syncCfg(true),
    "X")
  scene.btnMuteMusic.toggle = true
  scene.add scene.btnMuteMusic

  # btnBack
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


proc free*(scene: ConfigScene) =
  free scene.btnMuteSound
  free scene.btnMuteMusic
  free scene.labelSound
  free scene.labelMusic
  free scene.infoText
  free scene.btnBack
  freeData()


proc newConfigScene*(): ConfigScene =
  new result, free
  init result


method show*(scene: ConfigScene) =
  for i in 0..<VolSteps:
    scene.btnsSound[i].toggled = (i == sound)
    scene.btnsMusic[i].toggled = (i == music)
  scene.btnMuteSound.toggled = muteSound
  scene.btnMuteMusic.toggled = muteMusic


method event*(scene: ConfigScene, event: Event) =
  scene.eventScene event
  if event.kind == KeyDown:
    case event.key.keysym.scancode:
    of ScancodeF10:
      colliderOutline = not colliderOutline
    of ScancodeF11:
      showInfo = not showInfo
    of ScancodeEscape:
      game.scene = titleScene
    of ScancodeN:
      muteSound = not muteSound
      scene.btnMuteSound.toggled = muteSound
      syncCfg(true)
    of ScancodeM:
      muteMusic = not muteMusic
      scene.btnMuteMusic.toggled = muteMusic
      syncCfg(true)
    else:
      discard


method update*(scene: ConfigScene, elapsed: float) =
  scene.updateScene elapsed
  update playlist

