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
  MultiplierText* = ref object of Entity
    tweenA: Tween[MultiplierText,float]
    tweenS: Tween[MultiplierText,Scale]


proc init*(mt: MultiplierText, pos: Coord, text: string) =
  initEntity mt
  mt.layer = 1000
  let t = newTextGraphic bonusFont
  t.color = BonusTextColor
  t.lines = [text]
  mt.graphic = t
  mt.centrify()
  mt.pos = pos + SpriteDim.w / 2

  # alpha tween
  mt.tweenA = newTween[MultiplierText,float](
    mt,
    proc(t: MultiplierText): float = float(TextGraphic(t.graphic).color.a),
    proc(t: MultiplierText, val: float) =
      let color = TextGraphic(t.graphic).color
      TextGraphic(t.graphic).color = Color(
        r: color.r, g: color.g, b: color.b, a: uint8(val)))
  mt.tweenA.setup(255, 127, 0.75, 0)
  mt.tweenA.procedure = inSine
  mt.tweenA.play()

  # scale tween
  mt.tweenS = newTween[MultiplierText,Scale](
    mt,
    proc(t: MultiplierText): Scale = t.scale,
    proc(t: MultiplierText, val: Scale) = t.scale = val
  )
  mt.tweenS.setup(1.0, 4.0, 0.75, 0)
  mt.tweenS.procedure = inSine
  mt.tweenS.play()


proc newMultiplierText*(pos: Coord, text: string): MultiplierText =
  new result
  init result, pos, text


method update*(mt: MultiplierText, elapsed: float) =
  mt.updateEntity elapsed
  mt.tweenA.update elapsed
  mt.tweenS.update elapsed
  if not mt.tweenA.playing and not mt.tweenS.playing:
    mt.dead = true

