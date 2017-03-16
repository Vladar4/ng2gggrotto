import
  nimgame2 / [
    assets,
    audio,
    scene,
    texturegraphic,
    truetypefont,
    types,
  ]


const
  GameTitle*    = "Glorious Glacier Grotto"
  GameIcon*     = "" #TODO "gggrotto.png"
  GameVersion*  = "0.1 alpha"
  GameWidth*    = 960
  GameHeight*   = 600
  DefaultFont*  = "data/fnt/FSEX300.ttf"
  SpriteDim*: Dim     = (20, 20)
  SpriteOffset*: Dim  = (0, 0)


var
  introScene*, titleScene*, mainScene*: Scene
  defaultFont*: TrueTypeFont
  gfxData*: Assets[TextureGraphic]
  #TODO sfxData*: Assets[Sound]

proc loadData*() =
  # Font
  defaultFont = newTrueTypeFont()
  if not defaultFont.load(DefaultFont, 32):
    write stdout, "ERROR: Can't load font: ", DefaultFont
  # GFX
  gfxData = newAssets[TextureGraphic]("data/gfx",
    proc(file: string): TextureGraphic = newTextureGraphic(file))
  #TODO SFX
  #sfxData = newAssets[Sound]("data/sfx",
  #  proc(file: string): Sound = newSound(file))


proc freeData*() =
  defaultFont.free()
  for gfx in gfxData.values:
    gfx.free()
  #TODO
  #for sfx in sfxData.values:
  #  sfx.free()

