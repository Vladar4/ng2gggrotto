import
  nimgame2 / [
    assets,
    entity,
    nimgame,
    texturegraphic,
    tilemap,
    settings,
    types,
  ],
  data


type
  Map* = ref object of TileMap


proc init*(map: Map) =
  init TileMap(map)
  map.graphic = gfxData["tiles"]
  map.initSprite SpriteDim, SpriteOffset


proc free*(map: Map) =
  discard


proc newMap*(): Map =
  new result, free
  init result

