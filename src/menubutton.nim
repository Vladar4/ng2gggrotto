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
  ButtonAction* = proc(btn: MenuButton)

  MenuButton* = ref object of GuiButton
    action*: ButtonAction
    skin*: TextureGraphic
    label*: TextGraphic


proc init*(btn: MenuButton,
           pos: Coord,
           width: int,
           action: ButtonAction,
           text: string) =
  btn.skin = newTextureGraphic()
  discard btn.skin.assignTexture buttonMosaic.render(
    patternStretchBorder(width * 2, 4))
  btn.label = newTextGraphic defaultFont
  btn.label.lines = [text]
  GuiButton(btn).init(btn.skin, btn.label)
  btn.pos = pos
  btn.action = action


proc free*(btn: MenuButton) =
  if btn.label != nil:
    free btn.label


proc newMenuButton*(
    pos: Coord,
    width: int,
    action: ButtonAction,
    text: string): MenuButton =
  new result, free
  init result, pos, width, action, text


method onClick*(btn: MenuButton, mb = MouseButton.left) =
  if btn.action != nil:
    btn.action btn

