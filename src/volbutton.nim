import
  nimgame2 / [
    assets,
    gui/button,
    gui/widget,
    input,
    mosaic,
    textgraphic,
    texturegraphic,
    types,
  ],
  data


type
  VolKind* = enum vkSound, vkMusic

  VolGroup* = array[VolSteps, VolButton]

  VolButton* = ref object of GuiButton
    skin*: TextureGraphic
    kind*: VolKind
    value*: int
    group*: VolGroup


proc init*(btn: VolButton,
           pos: Coord,
           kind: VolKind,
           value: int) =
  btn.skin = newTextureGraphic()
  discard btn.skin.assignTexture buttonMosaic.render(
    patternStretchBorder(1, value))
  GuiButton(btn).init(btn.skin)
  btn.toggle = true
  btn.pos = pos
  btn.kind = kind
  btn.value = value


proc free*(btn: VolButton) =
  discard


proc newVolButton*(
    pos: Coord,
    kind: VolKind,
    value: int): VolButton =
  new result, free
  init result, pos, kind, value


method onClick*(btn: VolButton, mb = MouseButton.left) =
  if not btn.toggled:
    btn.toggled = true
  else:
    for i in 0..<VolSteps:
      if i == btn.value:
        continue
      btn.group[i].toggled = false
      # TODO set new volume (btn.kind)

