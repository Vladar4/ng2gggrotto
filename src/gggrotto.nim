import
  nimgame2 / [
    nimgame,
    settings,
  ],
  data,
  scene / [
    intro,
    title,
    main,
  ]


game = newGame()
if game.init(GameWidth, GameHeight,
             title = GameTitle,
             icon = GameIcon):
  # Init
  game.setResizable(true)
  game.minSize = (GameWidth div 2, int GameHeight div 2)
  game.centrify()
  loadData()
  # Scenes
  introScene = newIntroScene()
  titleScene = newTitleScene()
  mainScene  = newMainScene()
  # Run
  game.scene = introScene
  run game

