part of solarspace;

/// Beinhaltet alle Methoden zur Darstellung des Spiels.
/// 
/// @Authoren: Tim Wegner und Dmitrij Bauer
class View{
  /// Game-Container beinhaltet [gameArea] und [statusBar].
  final gameContainer = querySelector("#game_container");
  /// Zeitanzeige in der Statusleiste.
  final timer = querySelector("#timer");
  /// Container mit "Herz"-Icons.
  final hpContainer = querySelector("#hp_container");
  /// Statusleiste beinhaltet [timer] und [hpContainer].
  final statusBar = querySelector("#status_bar");
  /// Spielfeld beinhaltet [domElementsLevelObjects].
  final gameArea = querySelector("#game_area");
  /// Debug-Checkbox.
  final CheckboxInputElement debug  = querySelector("#menu_buttons").children[4]; /// Debugging
  /// Window.
  final gameWindow = window;
  /// Liste mit DOM-Tree-Elementen, die sich in [gameArea] befinden.
  List<Element> domElementsLevelObjects = List();

  /// Konstruktor.
  View();

  /// Liefert die Breite des Spielfeldes.
  /// 
  /// @Author Dmitrij Bauer
  double get gameAreaWidth => window.innerWidth.toDouble();

  /// Liefert die Höhe des Spielfeldes (Höhe der Statusleiste miteinberechnet).
  /// 
  /// @Author Dmitrij Bauer
  double get gameAreaHeight => window.innerHeight.toDouble() * 0.9;

  Storage get store => window.localStorage;

  /// Liefert True, falls das Device sich im Landscape-Modus befindet und False andernfalls.
  /// 
  /// @Author Dmitrij Bauer
  bool get isLandscapeMode => gameWindow.orientation != null && gameWindow.orientation != 0;

  /// Initialisiert den Game-Container. Dabei wird vorausgesetzt, dass
  /// der Game-Container zuvor zurückgesetzt wurde.
  /// 
  /// @Author Dmitrij Bauer
  initLevel(GameManager game){
    _createElement(game.activeLevel.playerCharacter);
    _createElements(game.activeLevel.staticObjects);
    _createElements(game.activeLevel.asteroids);
    _createElements(game.activeLevel.powerups);
    _createElements(game.activeLevel.enemies);
    _createHpContainer(game.activeLevel.playerCharacter.lifepoints);
    _updateStatusBar(game);
  }

  /// Erzeugt DOM-Tree-Elemente aus [levelObjects].
  /// 
  /// @Author Dmitrij Bauer
  void _createElements(List<LevelObject> levelObjects){
    for (LevelObject obj in levelObjects) {
      // Prüfe ob das LevelObjekt bereits im DOM-Tree vorhanden ist.
      bool isNew = !domElementsLevelObjects.any((el) => el.id == obj.id);
      // Der erste Teil der ID ist die Klasse des Objekts.
      int index = obj.id.indexOf("_");
      String class_ = obj.id.substring(0, index);
      if(isNew)_createElement(obj, elementClass : class_);
    }
  }

  /// Erzeugt aus [obj] ein Element im DOM-Tree mit der Klasse [elementClass].
  /// 
  /// @Author Dmitrij Bauer
  void _createElement(LevelObject obj, {String elementClass = "no class"}){
    Element el = Element.html("<div id='${obj.id}'></div>");
    if(elementClass != "no class")el.classes.add(elementClass);
    el.style.height = "${obj.collisionCircle.height}px";
    el.style.width = "${obj.collisionCircle.width}px";
    el.style.top = "${statusBar.clientHeight + obj.topLeftPoint.y}px";
    el.style.left = "${obj.topLeftPoint.x}px";
    el.style.transform = "rotate(${obj.rotationRad}rad)";
    domElementsLevelObjects.add(el);
    gameArea.append(el);
  }
  
  /// Entfernt zestörte bzw. inaktive [LevelObject] aus dem DOM-Tree.
  /// 
  /// @Author Dmitrij Bauer
  void _removeInactiveElements(List<LevelObject> levelObjects){
      // Zestörte LevelObjekte aus DOM-Tree entfernen
    domElementsLevelObjects.removeWhere((o){
      bool isRemoved = !levelObjects.any((obj) => obj.id == o.id);
      if(isRemoved) o.remove();
      return isRemoved;
    });
  }

  /// Aktualisiert die View anhand der Daten aus [Level] in [game].
  /// 
  /// @Author Dmitrij Bauer
  void update(GameManager game){
    _removeInactiveElements(game.activeLevel.allLevelObjects);
    _createElements(game.activeLevel.projectiles);
    _createElements(game.activeLevel.asteroids);
    _createElements(game.activeLevel.powerups);
    
    // LevelObjekte im DOM-Tree aktualisieren
    for (var obj in game.activeLevel.allLevelObjects) {
      Element el = domElementsLevelObjects.firstWhere((p) => p.id == obj.id, orElse: () => null);
      el.style.top = "${statusBar.clientHeight + obj.topLeftPoint.y}px";
      el.style.left = "${obj.topLeftPoint.x}px";
      el.style.transform = "rotate(${obj.rotationRad}rad)";
      // Prüfe ob das LevelObjekt aktuell unverwundbar ist.
      if(!obj.isInvulnerable) el.classes.remove("invulnerability");
      else el.classes.add("invulnerability");
    }
    _updateStatusBar(game);
  }

  /// Setzt den Game-Container zurück, dabei werden die Statusleiste
  /// und das Spielfeld geleert.
  /// 
  /// @Author Dmitrij Bauer
  void clearGameContainer(){
    timer.text = "";
    hpContainer.children.clear();
    domElementsLevelObjects.clear();
    gameArea.children.clear();
  }

  /// Erzeugt Leben-Symbole in der Statusleiste. Die Anzahl der Symbole wird durch [lifepoints] festgelegt.
  /// 
  /// @Author Dmitrij Bauer
  void _createHpContainer(int lifepoints){
    for(var i = 0; i < lifepoints; i++){
      Element el = Element.html("<div id='${i + 1}'></div>");
      el.classes.add("hp");
      hpContainer.append(el);
    }
  }

  /// Aktualisiert die Statusleiste anhand der Daten aus [game].
  /// 
  /// @Author Dmitrij Bauer
  void _updateStatusBar(GameManager game) {
    int lifepoints = game.activeLevel.playerCharacter.lifepoints;
    hpContainer.children.forEach((l){
      int id = int.parse(l.id);
      if(id > lifepoints) {
        l.classes.remove("hp_full");
        l.classes.add("hp_empty");
      }
      else {
        l.classes.remove("hp_empty"); 
        l.classes.add("hp_full"); 
      }
    });
    timer.text = game.elapsedTime;
  }

  /// Aktualisiert den Inhalt des Debugging-Containers.
  /// 
  /// @Author Dmitrij Bauer
  void updateDebugContainer({fps, orientEventCounter, onKeyDownEventCounter, a, b, g}){
    if(debug.checked) {
      querySelector("#debug_container").style.display = "block";
      if(fps != null)querySelector("#fps").text = "FPS: ${fps.round()}";
      if(orientEventCounter != null)querySelector("#onOrientEvent_counter").text = "onOrientEvents/s: ${orientEventCounter}";
      if(onKeyDownEventCounter != null)querySelector("#onKeyDownEvent_counter").text = "onKeyDownEvents/s: ${onKeyDownEventCounter}";
      if(a != null)querySelector("#alpha").text = "alpha: ${a}";
      if(b != null)querySelector("#beta").text = "beta: ${b}";
      if(g != null)querySelector("#gamma").text = "gamma: ${g}";
    }else querySelector("#debug_container").style.display = "none";
  }

  ///@Author Tim Wegner
  ///Wechselt die View zu der Landscape-Warnung.
  void changeToLandscapeWarning(){
    querySelector("#landscape").style.display = "block";
    querySelector("#portrait").style.display = "none";
  }

  ///@Author Tim Wegner
  ///Wechselt die View zu der Spiel-View im Portraitmodus.
  void changeToPortrait(){
    querySelector("#landscape").style.display = "none";
    querySelector("#portrait").style.display = "block";
  }

  ///@Author Tim Wegner
  ///Initialisiert das Startmenu.
  void initStartMenu(){
    querySelector("#start_menu").style.display = "block";
    querySelector("#menu_buttons").style.display = "flex";
  }

  ///@Author Tim Wegner
  ///Aktiviert den ContinueButton im Startmenu, wenn [Controller.maxLvl] groeßer ist als Zwei.
   void activateContinueStartMenu(int maxLvl){
    maxLvl > 1 ? querySelector("#continueButton").style.display = "block":
      querySelector("#continueButton").style.display = "none";
  }

  ///@Author Tim Wegner
  ///Wechselt aus dem Startmenu zu der Levelliste.
  ///[maxLvl] Das aktuelle maximale Level, welches freigeschalten wurden.
  void changeToLevellist(int maxLvl){
    querySelector("#menu_buttons").style.display = "none";
    _showLevelList(maxLvl);
  }

  ///@Author Tim Wegner
  ///Wechselt aus dem Startmenu zu der Highscoreuebersicht.
  void changeToHighscores(){
    querySelector("#menu_buttons").style.display = "none";
    _showHighscores();
  }

  ///@Author Tim Wegner
  ///Wechselt aus der Levelliste oder der Highscoreuebersicht
  ///zurueck zum Startmenu.
  void returnToStartMenu(){
    _hideHighscores();
    _hideLevelList();
    querySelector("#menu_buttons").style.display = "flex";
  }

  ///@Author Tim Wegner
  ///Wechselt aus dem Startmenu oder der Levelliste zu der Game-View.
  void startGame(){
    _hideLevelList();
    querySelector("#start_menu").style.display = "none";
    gameContainer.style.display = "block";
  }

  ///@Author Tim Wegner
  ///Wechselt aus der Game-View in den Win-Screen.
  ///[game] Der GameManager der die Zeit erspielte Zeit enthaehlt.
  ///[isHighscore] Ein boolescher Wert, der angibt, ob ein neuer Highscore erreicht wurde.
  void changeToWinScreen(GameManager game, bool isHighscore){
    gameContainer.style.display = "none";
    _showWinScreen(game, isHighscore);
  }

  ///@Author Tim Wegner
  ///Wechselt aus der Game-View in den Gameover-Screen.
  void changeToGameoverScreen(){
    gameContainer.style.display = "none";
    querySelector("#gameoverScreen").style.display = "block";
  }

  ///@Author Tim Wegner
  ///Wechselt aus dem Win- oder Gameover-Screen in die GameView.
  void changeToGame(){
    querySelector("#gameoverScreen").style.display = "none";
    querySelector("#winScreen").style.display = "none";
    gameContainer.style.display = "block";
  }

  ///@Author Tim Wegner
  ///Wechselt aus dem Win- oder Gameover-Screen in das Startmenu.
  void leaveGame(){
    querySelector("#winScreen").style.display = "none";
    querySelector("#gameoverScreen").style.display = "none";
    gameContainer.style.display = "none";
    initStartMenu();
  }

  ///@Author Tim Wegner
  ///Setzt ein Highscore fuer ein Level in der Highscoreuebersicht.
  ///[id] Die Id des Level.
  ///[time] Die neue Zeit,welche gesetzt werden soll.
  void setHighscoreForLevel(int id, int time){
    int minutes = time~/60;
    int seconds = (time % 60).toInt();
    String t = "${minutes}:${seconds < 10 ? '0' : ''}${seconds}";
    querySelector("#highscoreScore${id}").text = t;
  }

  ///@Author Tim Wegner
  ///Aktiviert alle Elemente aus der Levelliste und markiert noch nicht
  ///freigeschaltene Level rot.
  ///[maxLvl] Das momentan hoechste freigeschaltene Level. 
  void  _showLevelList(int maxLvl){
    querySelector("h2").style.display = "";
    querySelector("#levellistContainer").style.display = "block";
    querySelector("#abbruch").style.display = "block";
    for(int i = 1; i <= maxLvl;i++) {
      querySelector('#level${i}').style.color = "rgb(199, 199, 199)";
    }
  }

  ///@Author Tim Wegner
  ///Versteckt alle Elemente der Levelliste.
  void _hideLevelList(){
    querySelector("h2").style.display = "none";
    querySelector("#levellistContainer").style.display = "none";
    querySelector("#abbruch").style.display = "none";
  }

  ///@Author Tim Wegner
  ///Aktiviert alle Elemente der Highscoreuebersicht.
  void _showHighscores(){
    querySelector("h2").style.display = "";
    querySelector("#highscoreListContainer").style.display = "block";
  }

  ///@Author Tim Wegner
  ///Versteckt alle Elemente der Highscoreuebersicht.
  void _hideHighscores(){
    querySelector("h2").style.display = "none";
    querySelector("#highscoreListContainer").style.display = "none";
  }
  
  ///@Author Tim Wegner
  ///Aktiviert alle Elemente des Win-Screens und setzt die erspielte Zeit.
  ///[game] Der GameManager der die Zeit erspielte Zeit enthaehlt.
  ///[isHighscore] Ein boolescher Wert, der angibt, ob ein neuer Highscore erreicht wurde.
  void _showWinScreen(GameManager game,bool isHighscore){
    querySelector("#winScreen").style.display = "block";
    if(isHighscore){
      querySelector("#time").text = "New Highscore: ${game.elapsedTime}";
    }else{
      querySelector("#time").text = "Your Time: ${game.elapsedTime}";
    } 
  }
}