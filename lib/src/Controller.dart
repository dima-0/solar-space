part of solarspace;

/// Updaterate pro Sekunde.
const double fpsCap = 30;
/// Skalierungsfaktor des Offsets der Gyro-Steuerung.       
const double mobileFactor = 0.1;

/// Reagiert auf Benutzer-Interaktionen und koordiniert die 
/// Updates von [GameManager] und [View].
/// 
/// @Authoren: Tim Wegner und Dmitrij Bauer

class Controller{
  /// [View] Instanz zur Darstellung des Spiels.
  View _view = View();
  /// [LevelManager] beinhaltet alle geladenen Level, nach dem [LevelManager.load] aufgerufen wurde.
  LevelManager _levelManager;
  /// [GameManager] ist für die Verwaltung des Models (Spiels) zuständig.
  GameManager _gameManager = GameManager();
  /// Kalibrierungs-Wert von Beta (y-Achse).
  double _standartBeta = 0;
  /// Anzahl der Updates.
  int _frameCounter = 0;
  /// Zählt die Gyro-Steuerung Events (Debugging).
  int _onOrientEventCounter = 0;
  /// Zählt die Tastendruck Events (Debugging).
  int _onKeyDownEventCounter = 0;
  /// Anzahl der Updates pro Sekunde.
  double _fps = fpsCap;
  /// x-Offset, um den der Spieler beim nächsten Update auf der x-Achse
  /// bewegt wird. Beim Update wird der letzte gespeicherte Wert an 
  /// [GameManager.tick] übergeben.
  double _dx = 0;
  /// y-Offset, um den der Spieler beim nächsten Update auf der y-Achse
  /// bewegt wird. Beim Update wird der letzte gespeicherte Wert an 
  /// [GameManager.tick] übergeben.
  double _dy = 0;
  int maxLvl = 1;
  int currentLevelId;
  /// False, falls der Controller noch nicht vollständig initialisiert wurde und 
  /// True andernfalls.
  bool isInitialized = false;

  /// Konstruktor.
  /// 
  /// Initialisert die Update-Trigger.
  Controller(){
     _initUpdateTrigger();                                          
  }

  /// Initialisiert den Controller, dabei wird erst gewartet bis,
  /// [_levelManager] die Level geladen hat. Im Anschluss werden die restlichen
  /// Komponenten wie local storage und die Eventlistener, initialisert.
  void init() async{
    _levelManager = LevelManager(_view.gameWindow.location.href + "jsonFiles", 
                                      Vector2(view.gameAreaWidth, 
                                              view.gameAreaHeight));
    await levelManager.load();  
    initStorage();
    view.initStartMenu();
    _initActionListener();
    _initActionListenerForStartMenu(); 
  }

  View get view => this._view;
  LevelManager get levelManager => this._levelManager;
  GameManager get gameManager => this._gameManager;
  Storage get store => window.localStorage;


  /// Initialisiert die Update-Trigger.
  /// 
  /// @Author Dmitrij Bauer
  void _initUpdateTrigger(){
    // Löst das Update des Models und der View aus
    Timer.periodic(Duration(milliseconds: (1000 ~/ fpsCap)), (update) {
      if(view.isLandscapeMode){   // Wenn LandscapeMode dann Spiel pausieren und View zu Landscape aendern
        gameManager.pauseGame();
        view.changeToLandscapeWarning();
      }
      else{                       // Wenn PortraitMode dann Spiel weiterlaufen lassen und View zu Portrait ändern
        if(!isInitialized){       // Falls das Spiel bereits im Landscape-Modus gestartet wurde
          isInitialized = true;
          init();
          print("Level wurden geladen");
        }
        gameManager.resumeGame();
        view.changeToPortrait();
      } 
      switch (gameManager.state) {
        case State.RUNNING:
          gameManager.tick(_dx, _dy, _fps);
          view.update(gameManager);
          break;
        case State.PAUSED:
          _dx = 0;
          _dy = 0;
          break; 
        case State.FINISHED:
          if(gameManager.isVictory()){  // Wenn das Spiel beendet ist und gewonnen wurde, dann WinView und Highscore ueberpruefen.
            bool isnewHighscore = checkHighscore(gameManager.activeLevel.id, gameManager.elapsedTimeSec);
            view.changeToWinScreen(gameManager, isnewHighscore);
            insertInStorage(isnewHighscore,gameManager.activeLevel.id, gameManager.elapsedTimeSec);
            refreshMaxLevel();
          }else{                        // Wenn das Spiel verloren wurde, dann GameoverView. 
            view.changeToGameoverScreen();
          }
          view.update(gameManager);
          _dx = 0;
          _dy = 0;
          gameManager.reset();
          view.clearGameContainer();
          break;   
        default:
          break;
      }
      _frameCounter++;
    });

    // Setzt jede Sekunden verschiedene Zähler zurück und aktualisiert
    // das Debugging-Overlay.
    Timer.periodic(Duration(seconds: 1), (debugUpdate){
      _fps = _frameCounter.toDouble();
      _frameCounter = 0;
      if(gameManager.state == State.RUNNING) view.updateDebugContainer(fps:_fps, orientEventCounter: _onOrientEventCounter, onKeyDownEventCounter: _onKeyDownEventCounter);
      _onOrientEventCounter = 0;
      _onKeyDownEventCounter = 0;
    });
  }

  /// Initialisiert den Eventlistener.
  ///
  /// @Author Dmitrij Bauer

  void _initActionListener(){
    // Reagiert auf das Drücken der Pfeiltasten (Desktop-PC)
    view.gameWindow.onKeyDown.listen((KeyboardEvent ev){
      if(gameManager.state == State.RUNNING){
        _onKeyDownEventCounter++;
        switch (ev.which) {
          case KeyCode.UP:
            _dy = -1;
            break;
          case KeyCode.DOWN:
            _dy = 1;
            break;
          case KeyCode.LEFT:
            _dx = -1;
            break;
          case KeyCode.RIGHT:
            _dx = 1;
            break;      
          default:
            break;
        }
      }
    });

    // Reagiert auf das Loslassen der Pfeiltasten (Desktop-PC)
    view.gameWindow.onKeyUp.listen((KeyboardEvent ev){
      if(gameManager.state == State.RUNNING){
        switch (ev.which) {
          case KeyCode.UP:
            _dy = 0;
            break;
          case KeyCode.DOWN:
            _dy = 0;
            break;
          case KeyCode.LEFT:
            _dx = 0;
            break;
          case KeyCode.RIGHT:
            _dx = 0;
            break;      
          default:
            break;
        }
      }
    });
    
    // Reagiert auf Tastendruckevents der Maus (dem Desktop-PC)
    view.gameContainer.onClick.listen((MouseEvent ev){
      if(_gameManager.state == State.RUNNING){
        double x = ev.client.x;
        double y = ev.client.y - _view.statusBar.clientHeight; //Höhe der Statusleiste abziehen.
        Vector2 dest = Vector2(x, y);
        gameManager.activeLevel.playerCharacter.rotate(dest);
        gameManager.activeLevel.playerCharacter.shoot(dest);
      }
    });

    // Reagiert auf Events der Gyro-Steuerung
    view.gameWindow.onDeviceOrientation.listen((DeviceOrientationEvent ev){
      if(ev.alpha != null && ev.beta != null && ev.gamma != null){
        final alpha = ev.alpha;
        final beta = ev.beta;
        final gamma = ev.gamma;
        if(gameManager.state == State.RUNNING){
          _onOrientEventCounter++;
          view.updateDebugContainer(a:alpha.round(), b:beta.round(), g:gamma.round());
          _dx = (min(20, max(-20, gamma))) * mobileFactor;
          _dy = (min(_standartBeta + 20, max(_standartBeta - 20, beta)) - _standartBeta) * mobileFactor;
        }else{
          _standartBeta = (0.5 * _standartBeta) + (0.5 * beta);
        }
      }
    });
  }

  ///@Author Tim Wegner
  ///Initialisiert alle Actionlistener fuer das Startmenu.
  void _initActionListenerForStartMenu(){
    querySelector("#continue").onClick.listen((MouseEvent ev){
      currentLevelId = currentLevelId+1;
      if(currentLevelId <= levelManager.levelList.length){
        _loadNextLevel();
        view.changeToGame();
      }else{
        view.leaveGame();
      }
    });

    querySelector("#returnButtonWin").onClick.listen((MouseEvent ev){
      _view.leaveGame();
    });

    querySelector("#retryButton").onClick.listen((MouseEvent ev){
      gameManager.startLevel(_levelManager.getLevel(currentLevelId));
      view.initLevel(_gameManager);
      view.changeToGame();
    });

    querySelector("#returnButtonGameover").onClick.listen((MouseEvent ev){
      view.leaveGame();
    });

    querySelector("#levellistButton").onClick.listen((MouseEvent ev){
      view.changeToLevellist(maxLvl);
    });

    querySelector("#abbruch").onClick.listen((MouseEvent ev){
      view.returnToStartMenu();
    });

    querySelector("#highscoreButton").onClick.listen((MouseEvent ev){
      _view.changeToHighscores();
    });

     querySelector("#highscoreAbbruch").onClick.listen((MouseEvent ev){
      view.returnToStartMenu();
    });

    querySelector("#startButton").onClick.listen((MouseEvent ev){
      gameManager.startLevel(_levelManager.getLevel(1));
      currentLevelId = 1;
      view.initLevel(_gameManager);
      view.startGame();
    });

    querySelector("#continueButton").onClick.listen((MouseEvent ev){
      currentLevelId = maxLvl;
      _loadNextLevel();
      view.startGame();
    });
  }

  ///@Author Tim Wegner
  ///Laedt das naechste Level.
  void _loadNextLevel(){
    gameManager.startLevel(levelManager.getLevel(currentLevelId));
    view.initLevel(gameManager);
  }

  ///@Author Tim Wegner
  ///Initialisiert einen Actionlistener fuer ein Button aus der Levelliste.
  ///[id] Die Id des Levels und des dazugehoergigen Buttons.
  void initLevelListener(int id){
    querySelector("#level${id}").onClick.listen((MouseEvent ev){
      print(maxLvl);
      if(maxLvl >= id){
        view.startGame();
        gameManager.startLevel(_levelManager.getLevel(id));
        currentLevelId = id;
        view.initLevel(_gameManager);
      }
    });
  }

  ///@Author Tim Wegner
  ///Initialisiert den Local Storage.
  void initStorage()async{
    var jsonFile = {};
    if(_view.store.containsKey("solarspace")){
      jsonFile = await jsonDecode(_view.store["solarspace"]);
    }
      for (Level level in _levelManager.levelList) {
        if(!jsonFile.containsKey("level${level.id}")){
          jsonFile["level${level.id}"] = 0;
        }else{
          _view.setHighscoreForLevel(level.id, jsonFile["level${level.id}"]);
        } 
        initLevelListener(level.id); 
        int highscore = jsonFile["level${level.id}"];
        if(highscore > 0) maxLvl++;
      }
    if(maxLvl > levelManager.levelList.length){
      int levelAmount = levelManager.levelList.length;
      maxLvl = levelAmount;
    } 
    view.activateContinueStartMenu(maxLvl);
    store["solarspace"] = json.encode(jsonFile);
  }

  ///@Author Tim Wegner
  ///Fuegt eine erspielte Zeit in den Local Storage ein, wenn es ein neuer Highscore war.
  ///[isHighscore] Ein boolescher Wert, der angibt, ob ein neuer Highscore erreicht wurde.
  ///[levelID] Die Id des Levels, bei dem ein neuer Highscore erzielt wurde.
  ///[time] Der Zeit des neuen Highscores.
  void insertInStorage(bool isHighscore,int levelID, int time){
    if(isHighscore){
      Map scores = json.decode(_view.store["solarspace"]);
      scores["level${levelID}"] = time;
      _view.store["solarspace"] = json.encode(scores);
    }
  }

  ///@Author Tim Wegner
  ///Ueberprueft, ob ein neuer Highscore erspielt wurde.
  ///[levelID] Die Id des Levels, bei welchem der Highscore verglichen werden soll.
  ///[time] Die erspielte Zeit, welche mit dem aktuellen Highscore verglichen werden soll. 
  bool checkHighscore(int levelID, int time){
    Map scores = json.decode(_view.store["solarspace"]);
    int currentHighscore = scores["level${levelID}"];
    if(currentHighscore == 0 || currentHighscore > time){
      _view.setHighscoreForLevel(levelID, time);
      return true;
    }
    return false;
  }

  ///@Author Tim Wegner
  ///Berechnet [maxLvl] anhand der Highscores aus dem Local Storage neu.
  void refreshMaxLevel(){
    maxLvl = 1;
    Map storage = jsonDecode(_view.store["solarspace"]);
    for (Level level in levelManager.levelList) {
      int highscore = storage["level${level.id}"];
      if(highscore > 0) maxLvl++;
    }
    if(maxLvl > levelManager.levelList.length){
      int levelAmount = levelManager.levelList.length;
      maxLvl = levelAmount;
    } 
    view.activateContinueStartMenu(maxLvl);
  }
}