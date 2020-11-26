part of solarspace;

/// Verwaltet [Level] Instanzen.
/// 
/// @Authoren: Tim Wegner, Tobias Günther und Dmitrij Bauer.
class LevelManager{
  /// Liste mit geladenen [Level].
  List<Level> _levelList = List();
  /// Pfad zu den Json-Dateien.
  String _path;
  /// Spielfeldgröße (x: Breite / y: Höhe).
  Vector2 _gameSize;

  /// Konstruktor.
  /// 
  /// [_path] Pfad zu den Json-Dateien, welche Level-Parameter beinhalten.
  LevelManager(this._path, this._gameSize);

  ///@Author Tim Wegner
  ///Ließt alle vorhandenen JSON-Datein aus.
  void load() async{
    Map enemies_json = await this._getRawJson("${path}/enemies.json");

    for(var i = 1; i <= 10; i++){
      Level l = generateLevel(await _getRawJson("${path}/level/level${i}.json"), enemies_json, i); 
      levelList.add(l);
    }

  }

  /// @Author Tobias Guenther und Dmitrij Bauer
  /// Generiert das Level aus der JSON.
  /// [jsonLevel] Das Level als JSON Datei.
  /// [enemiesJson] Die Gegner als JSON Datei.
  /// [levelID] Die Level-ID.
  Level generateLevel(Map jsonLevel, Map enemiesJson,int levelID){
    Level level = Level(levelID, gameSize);
    for(var p in jsonLevel["player"]){
      Vector2 collisionBoxSize = Vector2(gameSize.y * p["scale"], gameSize.y * p["scale"]);
      Vector2 playerPosition = Vector2(gameSize.x * p["posx"], gameSize.y * p["posy"]);
      Vector2 rotation = Vector2(p["rotationx"], p["rotationy"]);
      LevelObject player = Playership(p["id"],playerPosition,collisionBoxSize,level,p["movement_speed"],p["hp"], rotation, p["projectile_speed"], p["projectile_scale"], p["reload_time"]);
      level.levelObjects["player"].add(player);
    }

    for(var statObj in jsonLevel["static_objects"]){
      Vector2 collisionBoxSize = Vector2(gameSize.y * statObj["scale"], gameSize.y * statObj["scale"]);
      Vector2 sOPosition = Vector2(gameSize.x*statObj["posx"], gameSize.y * statObj["posy"]);
      String id = LevelObject.generateValidId(level.staticObjects, statObj["id"]);
      LevelObject sObject = Obstacle(id, sOPosition ,collisionBoxSize,level, Vector2.zero());
      level.staticObjects.add(sObject);
    }

    for(var p in jsonLevel["powerups"]){
      for(var i in p["possible"]) level.possiblePowerups.add(i);
      level.maxPowerups = p["max_quantity"];
      level.powerupSpawnInterval = p["spawn_interval"];
    }

    for(var e in jsonLevel["enemies"]){
      Map enemy = enemiesJson[e["id"]];
      Vector2 collisionBoxSize = Vector2(gameSize.y * enemy["scale"], gameSize.y * enemy["scale"]);
      Vector2 pos = Vector2(gameSize.x * e["posx"], gameSize.y * e["posy"]);
      Vector2 rotation = Vector2(e["rotationx"], e["rotationy"]);
      String id = LevelObject.generateValidId(level.enemies, "enemy-${e["id"]}");
      double speed = enemy["movement_speed"];
      double projectileScale = enemy["projectile_scale"];
      double projectileSpeed = enemy["projectile_speed"];
      int reloadTime = enemy["reload_time"];
      double viewRadius = enemy["view_radius"] * min(gameSize.x , gameSize.y) + (collisionBoxSize.y / 2); //kürzeste Seite * Faktor + Radius(Hitbox)
      LevelObject enemyObj = Enemy.fromType(e["id"], id, pos, collisionBoxSize, level, speed, enemy["hp"], viewRadius, rotation, projectileSpeed, projectileScale, reloadTime);
      level.enemies.add(enemyObj);
    }

    for(var asteroid in jsonLevel["asteroids"]){
      double scale = asteroid["scale"];
      String id = asteroid["id"];
      double speed = asteroid["movement_speed"];
      int maxQuantity = asteroid["max_quantity"];
      double preferedDistanceAsteroids = 0.2; // Bevorzugte Distanz zu Asteroiden.
      double absoluteDistancePlayer = 0.5; // Absolute Distanz zum Spieler.
      double absoluteDistanceEnemies = 0.3; // Absolute Distanz zu Gegnern.
      _spawnAsteroids(level, id, maxQuantity, scale, speed, preferedDistanceAsteroids, absoluteDistancePlayer, absoluteDistanceEnemies);
    }
    return level;
  }

  /// @Author Tim Wegner
  /// Ließt eine JSON-Datei aus und decodiert sie.
  /// [path] Der Pfad an der die JSON-Datei liegt.
  Future<Map> _getRawJson(String path) async{
    var json =  await HttpRequest.getString(path);
    Map rawJson = jsonDecode(json);
    return rawJson;
  }

  /// Liefert eine Kopie vom [Level] Objekt mit der ID [index].
  /// Falls die Liste kein [Level] mit der ID [index] beinhaltet,
  /// wird null zurückgeliefert.
  /// 
  /// @Author Dmitrij Bauer
  Level getLevel(int index){
    return levelList.firstWhere((l) => l.id == index, orElse: () => null).clone();
  } 

  /// Liefert Liste mit allen geladenen [Level].
  List<Level> get levelList => this._levelList;

  /// Liefert den Pfad zu Verzeichnis, welches die Json-Dateien
  /// beinhaltet.
  String get path => this._path;

  /// Spielfeldgröße (x: Breite / y: Höhe).
  Vector2 get gameSize => this._gameSize;

  /// @Author Tobias Guenther
  /// Die Methode ist fuer das Spawnen der Asteroiden verantwortlich, welche zusaetzlich zu den unten aufgefuehrten Parametern noch die Rotation zufaellig bestimmt.
  /// [level] Das level, in welchem die Asteroiden spawnen sollen.
  /// [id] Der Praefix des Asteroiden.
  /// [n] Die Anzahl der Asteroiden, welche gespawnt werden sollen.
  /// [asteroidSize] Die Bevorzugte Groesse der Asteroiden, welche um einen zufaellig generierten Wert abweicht, damit die Asteroiden unterschiedlich gross werden.
  /// [speed] Die Geschwindigkeit der Asteroiden.
  /// [preferedDistanceToAsteroids] Die bevorzugte Distanz von Asteroiden untereinander.
  ///   Damit nicht zufaelligerweise alle Asteroiden zu nah beieinander spawnen, wird versucht die Distanz von Asteroiden zueinander gleich gross zu halten.
  ///   Falls die Anzahl der Asteoriden [n] sehr hoch eingestellt wird wird, um die Distanz zum Spieler und zu Gegnern beizubehalten, 
  ///   die Distanz der Asteroiden zueinander verringert. Sonst koennte es zu einer Endlosschleife kommen.
  /// [absoluteDistancePlayer] Die absolute Distanz von Asterodien zum Spieler. 
  ///   Diese Distanz kann nicht unterschritten werden, da Asterodien beim Levelstart nicht zu nah am Spieler spawnen sollten, um den Spieler Zeit zum reagieren zu geben.
  /// [absoluteDistanceEnemies] Die absolute Distanz von Asteroiden zu Gegnern. 
  ///   Die Distanz kann ebenfalls nicht unterschritten werden, da Asteroiden beim Levelstart nicht zu nah an Gegnern spanen sollten, um der gegnerischen KI Zeit zum ausweichen zu geben.
  void _spawnAsteroids(Level level, String id, int n, double asteroidSize, double speed, double preferedDistanceToAsteroids, double absoluteDistancePlayer, double absoluteDistanceEnemies) {
    // Spieler.
    LevelObject player = level.levelObjects["player"][0];
    double playerPosX = player.position.x / gameSize.x;
    double playerPosY = player.position.y / gameSize.y;
    Vector2 playerPosition = new Vector2(playerPosX, playerPosY);
    // Gegner.
    LevelObject enemy;
    double enemyPosX;
    double enemyPosY;
    Vector2 enemyPos;
    List<Vector2> enemyPosList = List();
    for (int k = 0; k < level.levelObjects["enemies"].length; k++) { // Speichere alle Positionen der Gegner.
      enemy = level.levelObjects["enemies"][k];
      enemyPosX = enemy.position.x / gameSize.x;
      enemyPosY = enemy.position.y / gameSize.y;
      enemyPos = new Vector2(enemyPosX, enemyPosY);
      enemyPosList.add(enemyPos);
    }
    // Asteroiden.
    double actualDistanceAsteroids = preferedDistanceToAsteroids;
    bool isTooCloseToExistingPos;
    double randPosY;
    double randRotY;
    double randPosX;
    double randRotX;
    int countAttempts;
    Vector2 randPos;
    Vector2 randRot;
    List<Vector2> randPosList = List();
    List<Vector2> randRotList = List();
    for (int i = 0; i < n; i++) { // Fuer alle Asteroiden.
      // Position.
      isTooCloseToExistingPos = true;
      countAttempts = 0;
      while(isTooCloseToExistingPos) { // Solange die Distanz zu allen bisher platzierten Asteroiden zu niedrig ist.
        isTooCloseToExistingPos = false;
        if (countAttempts >= 10)  {
          actualDistanceAsteroids /= 2; // Halbiere die gewuenschte Distanz bei zu vielen Durchlaeufen, um Endlosschleifen zu verhindern.
        }
        randPosY = Random().nextDouble();
        randPosX = Random().nextDouble();
        randPos = new Vector2(randPosX, randPosY);
        if (randPos.distanceTo(playerPosition) <= absoluteDistancePlayer) isTooCloseToExistingPos = true; // Distanz zum Spieler ...
        for (int j = 0; j < randPosList.length; j++) { // Fuer alle bisher platzierten Asteroiden.
          if (randPos.distanceTo(randPosList[j]) <= actualDistanceAsteroids) isTooCloseToExistingPos = true; // , zu einem Asteroiden ...
        }
        for (int l = 0; l < level.levelObjects["enemies"].length; l++) {
          if (randPos.distanceTo(enemyPosList[l]) <= absoluteDistanceEnemies) isTooCloseToExistingPos = true; // oder zu einem Gegner zu klein.
        }
        countAttempts++;
      }
      // Rotation.
      randPosList.add(randPos);
      randRotY = Random().nextDouble() * 10 - 5; // Ausrichtung und Geschwindigkeit festlegen.
      randRotX = Random().nextDouble() * 10 - 5; // Ausrichtung und Geschwindigkeit festlegen.
      if (randRotY <= 1 && randRotY >= -1) randRotY = Random().nextDouble() * 2 + 2; // Geschwindikeit nicht zu niedrig einstellen.
      if (randRotX <= 1 && randRotX >= -1) randRotX = Random().nextDouble() * 2 + 2; // Geschwindikeit nicht zu niedrig einstellen.
      randRot = new Vector2(randRotX, randRotY);
      randRotList.add(randRot);
    }
    // Platzierung.
    for (int i = 0; i < n; i++) { // Separierte Platzierung, damit alle Asteroiden gleichzeitig spawnen.
      double randAsteroidSize = Random().nextDouble() * 0.05 - 0.025; // Veraendert die groesse der Asteroiden geringfuegig.
      Vector2 collisionBoxSize = Vector2(gameSize.y * (asteroidSize + randAsteroidSize), gameSize.y * (asteroidSize + randAsteroidSize));
      Vector2 position = Vector2(gameSize.x * randPosList[i].x, gameSize.y * randPosList[i].y);
      Vector2 rotation = Vector2(randRotList[i].x, randRotList[i].y);
      LevelObject asteroid = Asteroid("${id}_${i}", position, collisionBoxSize, level, speed, rotation);
      level.asteroids.add(asteroid); 
    }
  }

}