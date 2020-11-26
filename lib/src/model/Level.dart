part of solarspace;

/// Enthält Instanzen der [LevelObject], die im Spiel vorhanden sind.
/// 
/// @Author Dmitrij Bauer
class Level{
  /// Level-ID
  int _id;
  /// Spielfeldgröße (x: Breite / y: Höhe).
  Vector2 _gameSize;
  /// Anzahl der [Powerup], die gleichzeitig auf dem Spielfeld sein können.
  int _maxPowerups = 0;
  /// Spawn-Intervall der [Powerup] in Sekunden.
  int _powerupSpawnInterval = 0;
  /// Liste mit erlaubten [Powerup] für dieses [Level].
  List<String> _possiblePowerups = List();
  /// Map mit allen [LevelObject].
  ///
  /// Key: Typ der Spielfigur | Value: Liste mit [LevelObject].
  Map<String, List<LevelObject>> _levelObjects = {"player":List(), 
                                                  "staticObjects":List(),
                                                  "powerups":List(),
                                                  "projectiles":List(),
                                                  "enemies":List(),
                                                  "asteroids":List()};

  /// Konstruktor.
  /// 
  /// [_id] Level-ID.
  /// [_gameSize] Spielfeldgröße (x: Breite / y: Höhe).
  Level(this._id, this._gameSize);

  /// Spielfeldgröße (x: Breite / y: Höhe).
  Vector2 get gameSize => this._gameSize;

  /// Level-ID
  int get id => this._id;

  /// Spawn-Intervall der [Powerup].  
  int get powerupSpawnInterval => this._powerupSpawnInterval;

  /// Setzt Spawn-Intervall der [Powerup].
  set powerupSpawnInterval(int value) => this._powerupSpawnInterval = value;

  /// Anzahl der [Powerup], die gleichzeitig auf dem Spielfeld sein können.
  int get maxPowerups => this._maxPowerups;

  /// Setzt die Anzahl der [Powerup], die gleichzeitig auf dem Spielfeld sein können.
  set maxPowerups(int value) => this._maxPowerups = value;

  /// Map mit allen [LevelObject].
  ///
  /// Key: Typ der Spielfigur | Value: Liste mit [LevelObject].
  Map<String, List<LevelObject>> get levelObjects => this._levelObjects;

  /// Liste mit erlaubten [Powerup] für dieses [Level].
  List<String> get possiblePowerups => this._possiblePowerups;

  /// Liste mit allen [Obstacle], die sich aktuell auf dem Spielfeld befinden.
  List<LevelObject> get staticObjects => levelObjects["staticObjects"];

  /// Liste mit allen [Powerup], die sich aktuell auf dem Spielfeld befinden.
  List<LevelObject> get powerups => levelObjects["powerups"];

  /// Liefert alle [Projectile], die dem [Spaceship] Typ [owner] gehören und sich
  /// aktuell auf dem Spielfeld befinden.
  /// 
  /// [owner] (Optional) Typ, nach dem gefiltert werden soll (nicht null).
  /// Falls [owner] nicht übergeben wird, werden alle [Projectile], die sich aktuell auf dem Spielfeld
  /// befinden, zurückgegeben.
  List<LevelObject> getFilteredProjectiles({String owner = ""}){
    List<LevelObject> ret = List();
    for (Projectile projectile in projectiles) {
      if(projectile._owner.id.contains(owner)) ret.add(projectile);
    }
    return ret;
  }

  /// Liefert alle [Projectile], die sich aktuell auf dem Spielfeld befinden.
  List<LevelObject> get projectiles => levelObjects["projectiles"];

  /// Liefert alle [Enemy], die sich aktuell auf dem Spielfeld befinden.
  List<LevelObject> get enemies => levelObjects["enemies"];

  /// Liefert alle [Asteroid], die sich aktuell auf dem Spielfeld befinden.
  List<LevelObject> get asteroids => levelObjects["asteroids"];

  /// Liefert [Playership].
  Playership get playerCharacter => levelObjects["player"][0];

  /// Liefert alle [MoveableObject] (ohne [Playership]), die sich auf dem Spielfeld befinden.
  /// Die Liste enthält somit [Projectile], [Asteroid] und [Enemy].
  List<LevelObject> get moveableObjects => projectiles + asteroids + enemies;

  /// Liefert alle [LevelObject], die sich aktuell auf dem Spielfeld befinden.
  List<LevelObject> get allLevelObjects => (levelObjects["player"] + staticObjects + powerups + projectiles + enemies + asteroids);

  /// Liefert eine Liste mit festen Positionen an der Kante. Je Kante werden
  /// 4 Position generiert, die einen Abstand von 25% zueinadner haben.
  List<Vector2> get _edgePositions{
    List<Vector2> ret = List();
    
    // obere Wand
    for (var i = 0.0; i <= 1; i += 0.25) {
      Vector2 p = Vector2(gameSize.x * i, 0);
      if(!ret.contains(p)) ret.add(p);
    }
    // linke Wand
    for (var i = 0.0; i <= 1; i += 0.25) {
      Vector2 p = Vector2(0, gameSize.y * i);
      if(!ret.contains(p)) ret.add(p);
    }
    // untere Wand
    for (var i = 0.0; i <= 1; i += 0.25) {
      Vector2 p = Vector2(gameSize.x * i, gameSize.y);
      if(!ret.contains(p)) ret.add(p);
    }
    // rechte Wand
    for (var i = 0.0; i <= 1; i += 0.25) {
      Vector2 p = Vector2(gameSize.x, gameSize.y * i);
      if(!ret.contains(p)) ret.add(p);
    }
    return ret;
  }

  /// Liefert eine Kopie dieser Level-Instanz.
  Level clone(){
    Level levelCopy = Level(id, Vector2.copy(gameSize));
    LevelObject player = playerCharacter.clone();
    player.level = levelCopy;
    levelCopy.levelObjects["player"].add(player);

    staticObjects.forEach((w) {
      LevelObject obj = w.clone();
      obj.level = levelCopy;
      levelCopy.staticObjects.add(obj);
    });

    enemies.forEach((w) {
      LevelObject obj = w.clone();
      obj.level = levelCopy;
      levelCopy.enemies.add(obj);
    });

    powerups.forEach((w) {
      LevelObject obj = w.clone();
      obj.level = levelCopy;
      levelCopy.powerups.add(obj);
    });

    projectiles.forEach((w) {
      LevelObject obj = w.clone();
      obj.level = levelCopy;
      levelCopy.projectiles.add(obj);
    });

    asteroids.forEach((w) {
      LevelObject obj = w.clone();
      obj.level = levelCopy;
      levelCopy.asteroids.add(obj);
    });

    possiblePowerups.forEach((w){
      levelCopy.possiblePowerups.add(w);
    });

    levelCopy.maxPowerups = maxPowerups;
    levelCopy.powerupSpawnInterval = powerupSpawnInterval;
    return levelCopy;
  }

  /// Wählt einen zufälligen [Vector2] aus [_edgePositions].
  /// 
  /// [shouldNotOccur] (Optional) [Vector2], der nicht vorkommen soll.
  Vector2 pickRandomPos({shouldNotOccur}){
    List<Vector2> posList = _edgePositions;
    Vector2 pos;
    Random rand = Random();
    do{
      int i = rand.nextInt(posList.length);
      pos = posList[i];
    }while(shouldNotOccur != null && pos == shouldNotOccur);
    return pos;
  }

}