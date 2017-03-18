import
  nimgame2 / [
    assets,
    collider,
    entity,
    nimgame,
    types,
  ],
  data,
  map


const
  ItemsAmount*    = 25
  ItemAssetSmall  = "fish"
  ItemAssetBig    = "jam"
  ItemAssetSpawn  = "egg"


type
  ItemKind* = enum ikSmall, ikBig, ikSpawn
  Item* = ref object of Entity
    kind*: ItemKind


proc init*(item: Item, kind: ItemKind, mapPos: MapPos) =
  item.initEntity()
  item.tags.add "item"

  item.kind = kind
  case kind:
  of ikSmall:
    item.graphic = gfxData[ItemAssetSmall]
  of ikBig:
    item.graphic = gfxData[ItemAssetBig]
  of ikSpawn:
    item.graphic = gfxData[ItemAssetSpawn]

  item.collider = item.newBoxCollider(SpriteDim / 2 - SpriteOffset, SpriteDim)
  item.center = SpriteOffset
  item.pos = mapPos.toCoord


proc newItem*(kind: ItemKind, mapPos: MapPos): Item =
  new result
  init result, kind, mapPos

