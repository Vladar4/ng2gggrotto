import
  nimgame2 / [
    nimgame,
    settings
  ],
  data,
  scene/intro


game = newGame()
if game.init(GameWidth, GameHeight,
             title = GameTitle,
             icon = GameIcon):
  game.setResizable(true)
  game.minSize = (480, 300)
  game.scene = newIntroScene()
  game.run

