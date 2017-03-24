import
  os,
  nimgame2 / [
    audio,
  ],
  data


const
  VolValue: array[VolSteps, Volume] = [
    Volume Volume.high div 8,
    Volume.high div 4,
    Volume.high div 2,
    Volume (Volume.high.float / 1.5),
    Volume.high]


type
  Cfg = object
    sound*, music*: byte
    muteSound*, muteMusic*: bool


var
  cfgDir, cfgPath: string


proc updateCfg(cfg: Cfg) =
  sound = cfg.sound
  music = cfg.music
  muteSound = cfg.muteSound
  muteMusic = cfg.muteMusic
  # actually set the values
  setSoundVolume(if muteSound: 0
                 else: VolValue[sound])
  setMusicVolume(if muteMusic: 0
                 else: VolValue[music])


proc syncCfg*(save = false) =
  var
    f: File
    cfg: Cfg
  let
    size = sizeof(cfg)

  cfgDir = getConfigDir().joinPath("gggrotto")
  cfgPath = cfgDir.joinPath("config.dat")

  if not save:
    # read from the config file
    if f.open(cfgPath, fmRead, size):
      if f.readBuffer(addr(cfg), size) == size:
        updateCfg cfg
        f.close()
        return

  # create a new config file
  discard existsOrCreateDir(cfgDir)
  if not f.open(cfgPath, fmWrite, size):
    echo "ERROR: Can't create config file in the ", cfgDir
    return

  cfg.sound = sound
  cfg.music = music
  cfg.muteSound = muteSound
  cfg.muteMusic = muteMusic
  updateCfg cfg

  discard f.writeBuffer(addr(cfg), size)
  f.close()

