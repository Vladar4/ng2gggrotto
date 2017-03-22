import
  nimgame2 / [
    nimgame,
    settings,
    types,
  ],
  data,
  scene / [
    config,
    info,
    intro,
    title,
    main,
    hiscore,
  ]


game = newGame()
if game.init(GameWidth, GameHeight,
             title = GameTitle,
             icon = GameIcon,
             bgColor = Color(r: 102, g: 204, b:255, a: 255)):
  # Init
  game.setResizable(true)
  game.minSize = (GameWidth div 2, int GameHeight div 2)
  game.centrify()
  loadData()
  # Scenes
  introScene = newIntroScene()
  titleScene = newTitleScene()
  configScene = newConfigScene()
  infoScene = newInfoScene()
  hiscoreScene = newHiscoreScene()
  # Run
  game.scene = introScene
  run game

