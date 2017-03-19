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
  ItemAssetSmall  = "fish"
  ItemAssetBig    = "jam"
  ItemAssetSpawn  = "egg"
  BonusSmall      = 10
  BonusBig        = 50
  BonusSpawn      = 100


type
  ItemKind* = enum ikSmall, ikBig, ikSpawn
  Item* = ref object of Entity
    kind*: ItemKind
    mapPos*: MapPos
    spawn*: bool


proc init*(item: Item, kind: ItemKind, mapPos: MapPos) =
  item.initEntity()
  item.tags.add "item"
  item.spawn = false

  item.kind = kind
  case kind:
  of ikSmall:
    item.graphic = gfxData[ItemAssetSmall]
  of ikBig:
    item.graphic = gfxData[ItemAssetBig]
  of ikSpawn:
    item.tags.add "spawn"
    item.graphic = gfxData[ItemAssetSpawn]

  item.collider = item.newBoxCollider(
    SpriteDim / 2 - SpriteOffset, SpriteDim * 0.9)
  item.collider.tags.add("player")
  item.center = SpriteOffset
  item.pos = mapPos.toCoord
  item.mapPos = mapPos


proc newItem*(kind: ItemKind, mapPos: MapPos): Item =
  new result
  init result, kind, mapPos


method onCollide*(item: Item, target: Entity) =
  if "player" in target.tags:
    item.dead = true
    item.spawn = true
    echo scoreMultiplier
    case item.kind:
    of ikSmall:
      playerScore += BonusSmall * scoreMultiplier
    of ikBig:
      playerScore += BonusBig * scoreMultiplier
    of ikSpawn:
      playerScore += BonusSpawn * scoreMultiplier
      inc playerGoal

