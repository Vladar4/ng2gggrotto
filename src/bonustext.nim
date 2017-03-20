import
  nimgame2 / [
    assets,
    nimgame,
    entity,
    textgraphic,
    tween,
    types,
  ],
  data


type
  BonusText* = ref object of Entity
    tween: Tween[BonusText,Coord]


proc init*(bt: BonusText, pos: Coord, text: string) =
  initEntity bt
  bt.layer = 1000
  let t = newTextGraphic bonusFont
  t.color = BonusTextColor
  t.lines = [text]
  bt.graphic = t
  bt.centrify()
  bt.pos = pos + SpriteDim.w / 2
  bt.tween = newTween[BonusText,Coord](
    bt,
    proc(t: BonusText): Coord = t.pos,
    proc(t: BonusText, val: Coord) = t.pos = val
  )
  bt.tween.setup(bt.pos, bt.pos + (0.0, -float(SpriteDim.h)), 0.5, 0)
  bt.tween.procedure = linear
  bt.tween.play()


proc newBonusText*(pos: Coord, text: string): BonusText =
  new result
  init result, pos, text


method update*(bt: BonusText, elapsed: float) =
  bt.updateEntity elapsed
  bt.tween.update elapsed
  if not bt.tween.playing:
    bt.dead = true

