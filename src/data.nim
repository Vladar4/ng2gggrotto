import
  nimgame2 / [
    assets,
    audio,
    input,
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


type
  MapPos* = tuple[x, y: int]


proc toCoord*(pos: MapPos): Coord {.inline.} =
  (pos.x * SpriteDim.w + SpriteOffset.w, pos.y * SpriteDim.h + SpriteOffset.h)


proc toMapPos*(pos: Coord, size = SpriteDim): MapPos {.inline.} =
  (int(pos.x / size.w.float), int(pos.y / size.h.float))


var
  introScene*, titleScene*, mainScene*: Scene
  defaultFont*: TrueTypeFont
  gfxData*: Assets[TextureGraphic]
  #TODO sfxData*: Assets[Sound]
  moveUp* = [ScancodeUp, ScancodeW]
  moveDown* = [ScancodeDown, ScancodeS]
  moveLeft* = [ScancodeLeft, ScancodeA]
  moveRight* = [ScancodeRight, ScancodeR]
  # amount
  ItemsAmount* = 32
  GoalsAmount* = 4
  EnemiesAmount* = 8
  # player
  DefaultSpeed* = 0.6
  SpeedAddition* = 0.015
  speed* = DefaultSpeed
  StartPlayerLives* = 3
  playerLives* = 3
  playerScore* = 0
  playerTargetGoal* = 0
  playerGoal* = 0
  scoreMultiplier* = 1


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

