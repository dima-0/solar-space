part of solarspace;

/// Die abstrakte Klasse [LevelObject] dient als Basisklasse für alle Objekte auf dem Spielfeld. weiteres Verhalten muss von Unterklassen
/// ergänzt werden.
/// 
/// @Author Dmitrij Bauer
abstract class LevelObject {
  /// ID vom [LevelObject].
  /// 
  /// Die ID wird aus einem Prefix und einer nummerischen ID zusammengesetzt.
  /// Dabei ist das Prefix der Typ vom [LevelObject] und die ID ein zufälliger Wert.
  String _id;
  /// Hitbox, wird für Kollisionsabfragen genutzt.
  CollisionCircle _collisionCircle;
  /// Aktuelle Position des Mittelpunktes vom [LevelObject].
  Vector2 _position;
  /// Aktuelle Rotation des [LevelObject] um den Mittelpunkt.
  Vector2 _rotation;
  /// Levelinstanz, in der sich [this] aktuell befindet.
  Level _level;
  /// Liefert True, falls das [LevelObject] noch aktiv ist und False andernfalls.
  bool _isActive = true;
  /// Maximale Anzahl an Lebenspunkten.
  int _maxLifepoints;
  /// Aktelle Anzahl der Lebenspunkte des [LevelObject]
  int _lifepoints;
  /// Stopuhr, die misst wie lange [this] bereits unverwundbar ist.
  Stopwatch _invulnerabilityTimer = new Stopwatch();
  

  /// Konstruktor
  /// 
  /// [_id] Die ID soll folgender Form haben: <prefix>_<id>.
  /// 
  /// [_position] Startposition des Mittelpunktes.
  /// 
  /// [collisionBoxSize] Größe der Hitbox, dabei ist x die Breite und y die Höhe.
  /// 
  /// [_level] Levelinstanz, der das [LevelObject] zugewiesen werden soll.
  /// 
  /// [_lifepoints] Maximale Anzahl der Lebenspunkte.
  /// 
  /// [_rotation] Startrotation.
  LevelObject(this._id, this._position, Vector2 collisionBoxSize, this._level, this._lifepoints, this._rotation){
    this._collisionCircle = CollisionCircle(position, collisionBoxSize);
    _maxLifepoints = lifepoints;
  }

  /// ID vom [LevelObject].
  /// 
  /// Die ID wird aus einem Prefix und einer nummerischen ID zusammengesetzt.
  /// Dabei ist das Prefix der Typ vom [LevelObject] und die ID ein zufälliger Wert.
  /// 
  /// Beispiel: <prefix>_<id> => projectile_2
  String get id => this._id;
  
  /// Hitbox, wird für Kollisionsabfragen genutzt.
  CollisionCircle get collisionCircle => this._collisionCircle;

  /// Aktuelle Position des Mittelpunktes vom [LevelObject].
  Vector2 get position => this._position;

  /// Aktuelle Rotation des [LevelObject] um den Mittelpunkt.
  Vector2 get rotation => this._rotation;

  /// Aktuelle Rotation als Rad.
  double get rotationRad => atan2(rotation.y, rotation.x);

  /// Koordinaten des oberen linken Punktes.
  Vector2 get topLeftPoint => Vector2(collisionCircle.left, collisionCircle.top);

  /// Levelinstanz, in der sich [this] aktuell befindet.
  Level get level => this._level;

  /// Setzt die Levelinstanz vom [LevelObject]
  set level(Level lvl) => this._level = lvl;

  /// Aktelle Anzahl der Lebenspunkte des [LevelObject]
  int get lifepoints => this._lifepoints;

  /// Liefert True, falls das [LevelObject] noch aktiv ist und False andernfalls.
  bool get isActive => this._isActive;

  /// Setzt [value] bei [isActive].
  set isActive(bool value) => this._isActive = value;

  /// Liefert eine Stopuhr, die misst wie lange [this] bereits unverwundbar ist. 
  Stopwatch get invulnerabilityTimer => this._invulnerabilityTimer;

  /// True falls [this] unverwundwar ist und False andernfalls.
  bool get isInvulnerable => invulnerabilityTimer.isRunning;

  /// Rotiert das [LevelObject].
  /// 
  /// [destPoint]: Koordinaten des Punktes, in wessen Richtung das [LevelObject]
  /// rotiert werden soll.
  void rotate(Vector2 destPoint){
    this._rotation = (destPoint - position).normalized(); // Vektor AB = B - A
  }

  /// Setzt die Position des Mittelpunktes vom [LevelObject].
  set position(Vector2 pos){
    this._position = pos.clone();
  } 

  /// Definiert ein Verhalten bei Kollision mit [other].
  void actionOnCollide(LevelObject other);
  
  /// Aktualisiert [position] und prüft auf Kollision
  /// mit dem Spielfeldrand.
  /// 
  /// Bei einer Kollision mit dem Spielfeldrand wird das [LevelObject] 
  /// aus der Kollision "herausgezogen"
  /// 
  /// Um weiteres Verhalten, wie z.B. das Prüfen auf Kollision mit anderen [LevelObject], 
  /// hinzuzufügen, muss diese Methode von Unterklassen überschrieben werden, dabei muss 
  /// super.move() aufgerufen werden (falls Kollisionsprüfung mit dem Spielfeldrand
  /// gewünscht ist).
  /// 
  /// [dx] (Optional) x-Offset, um welchen die Position auf der x-Achse verschoben werden soll.
  /// 
  /// [dy] (Optional) y-Offset, um welchen die Position auf der y-Achse verschoben werden soll.
  /// 
  /// [pxPerFrame] (Optional) Anzahl der Pixel, um die das [LevelObject] verschoben werden soll.
  void move({double dx, double dy, pxPerFrame});

  /// Berechnet die "nächste" Position und setzt diese in [position].
  /// Dabei wird bei der Berechnung die [velocity](Geschwindigkeit/Richtung) mit der [speed] des [LevelObject]
  /// und [pxPerFrame] skaliert. Die [velocity] wird anschließend zur der aktuellen [preferedPosition]
  /// hinzuaddiert.
  /// 
  /// [dx] (Optional) x-Offset, um welchen die Position auf der x-Achse verschoben werden soll.
  /// 
  /// [dy] (Optional) y-Offset, um welchen die Position auf der y-Achse verschoben werden soll.
  /// 
  /// [pxPerFrame] (Optional) Anzahl der Pixel, um die das [LevelObject] verschoben werden soll.
  void _updatePosition({double dx, double dy, double pxPerFrame});
  
  /// Reduziert [lifepoints] um [number], dabei gilt [lifepoints] >= 0.
  void decreaseLifepointsBy(int number);

  /// Erhöht [lifepoints] um [number], dabei gilt [lifepoints] <= [_maxLifepoints].
  void increaseLifepointsBy(int number);

  /// Liefert eine Kopie von [this].
  LevelObject clone();

  /// Startet die Timer/Stopuhren  in [LevelObject].
  /// 
  /// Verhalten muss von Unterklassen, die diese Funktionalität
  /// benötigen, überschrieben werden.
  void start(){}
  
  /// Stoppt die Timer/Stopuhren in [LevelObject].
  /// 
  /// Verhalten muss von Unterklassen, die diese Funktionalität
  /// benötigen, überschrieben werden.
  void stop(){}
  
  /// Pausiert die Timer/Stopuhren in [LevelObject].
  /// 
  /// Verhalten muss von Unterklassen, die diese Funktionalität
  /// benötigen, überschrieben werden.
  void pause(){}

  /// Setzt die Timer/Stopuhren in [LevelObject] fort.
  /// 
  /// Verhalten muss von Unterklassen, die diese Funktionalität
  /// benötigen, überschrieben werden.
  void resume(){}

  /// Aktualisiert die Timer/Stopuhren in [LevelObject].
  ///
  /// Verhalten muss von Unterklassen, die diese Funktionalität
  /// benötigen, überschrieben werden.
  void updateTimer(){}

  /// Generiert eine einzigartige und gültige ID, nach folgendem Muster:
  /// <prefix>_<id> => Beispiel: projectile_2
  /// 
  /// [list] Liste mit [LevelObject], bzw. IDs die nicht vorkommen dürfen (nicht null).
  /// 
  /// [prefix] Typ des [LevelObject]
  static String generateValidId(List<LevelObject> list, String prefix){
    String objectId;
      do{
        int random = Random().nextInt(list.length + 1) + 1;
        objectId = "${prefix}_${random}";
      }while(list.any((p) => p.id == objectId));
    return objectId;  
  }

  /// Liefert eine zufällige Position auf dem Spielfeld oder null,
  /// falls keine passende Position gefunden wird.
  /// 
  /// [objectsToAvoid] Liste mit [LevelObject], die bei Wahl der 
  /// Position berücksichtigt werden (nicht null).
  /// 
  /// [gameSize] Spielfeldgröße (nicht null).
  /// 
  /// [objSize] Größe des [CollisionCircle] vom [LevelObject] (nicht null).
  /// 
  /// [player] (Optional) Instanz eines [LevelObject], die bei Wahl der 
  /// Position berücksichtigt werden soll
  /// 
  /// [distanceToPlayer] (Optional) Minimale Distanz zum [player].
  /// 
  /// [maxAttempts] (Optional) Maximale Anzahl der Versuche, um die unendliche Suche nach einer Position zu vermeiden. 
  static Vector2 generateRandomPosition(List<LevelObject> objectsToAvoid, Vector2 gameSize, Vector2 objSize, {LevelObject player, int distanceToPlayer = 1, int maxAttempts = 150}){
    CollisionCircle circle = CollisionCircle(Vector2(0, 0), objSize);
    Random rand = Random();
    double minx = 0 + circle.radius;
    double maxx = gameSize.x - circle.radius;
    double miny = 0 + circle.radius;
    double maxy = gameSize.y - circle.radius;
    double x = minx;
    double y = miny;
    bool isCollidingWithObjects = false;
    int attemptCounter = 0;
    do{
      x = (rand.nextDouble() * (maxx - minx)) + minx;
      y = (rand.nextDouble() * (maxy - miny)) + miny;
      circle.position.setValues(x, y);
      if(player != null)isCollidingWithObjects = circle.position.distanceTo(player.collisionCircle.position) <= ((circle.radius + player.collisionCircle.radius) * distanceToPlayer);
      isCollidingWithObjects = isCollidingWithObjects || objectsToAvoid.any((o) => circle.isCollidingWith(o.collisionCircle));
      attemptCounter++;
    }while(isCollidingWithObjects && attemptCounter < maxAttempts);
    
    if(!isCollidingWithObjects){
      return Vector2(x, y);
    }
    return null;
  }
}
