part of solarspace;

/// @Author Dmitrij Bauer und Tobias Guenther
/// Die Klasse Enemy beschreibt den Gegner, welcher hauptsaechlich durch seine KI gepraegt ist.
abstract class Enemy extends Spaceship{
  double _viewRadius;
  Vector2 _randomTargetPos;

  /// Konstruktor.
  /// [id] Die ID soll folgender Form haben: <prefix>_<id> (nicht null).
  /// [position] Startposition des Mittelpunktes (nicht null).
  /// [collisionBoxSize] Größe der Hitbox, dabei ist x die Breite und y die Höhe (nicht null).
  /// [level] Levelinstanz, die dem [Enemy] zugewiesen werden soll (nicht null).
  /// [speed] Geschwindigkeit des [Enemy].
  /// [lifepoints] Anzahl an Leben.
  /// [_viewRadius] Sichtweite des [Enemy].
  /// [rotation] Startrotation (nicht null).
  /// [projectileSpeed] Die Geschwindigkeit der Projektile des [Enemy].
  /// [projectileScale] Die Groesse der Projektile des [Enemy].
  /// [reloadTime] Die Nachladedauer, bis ein neues Prjektil abgefeutert werden kann.
  Enemy(String id, Vector2 position, Vector2 collisionBoxSize, Level level, double speed, int lifepoints, this._viewRadius, Vector2 rotation, double projectileSpeed, double projectileScale, int reloadTime) : 
  super(id, position, collisionBoxSize, level, speed, lifepoints, rotation, projectileSpeed, projectileScale, reloadTime){
    randomTargetPos = level.pickRandomPos();
  }

  /// Fabrikmethode, um einen spezifischen Gegnertypen herzustellen.
  /// [type] Der spezifische Gegnertype als String.
  /// [id] Die ID soll folgender Form haben: <prefix>_<id> (nicht null).
  /// [position] Startposition des Mittelpunktes (nicht null).
  /// [collisionBoxSize] Größe der Hitbox, dabei ist x die Breite und y die Höhe (nicht null).
  /// [level] Levelinstanz, die dem [Enemy] zugewiesen werden soll (nicht null).
  /// [speed] Geschwindigkeit des [Enemy].
  /// [lifepoints] Anzahl an Leben.
  /// [_viewRadius] Sichtweite des [Enemy].
  /// [rotation] Startrotation (nicht null).
  /// [projectileSpeed] Die Geschwindigkeit der Projektile des [Enemy].
  /// [projectileScale] Die Groesse der Projektile des [Enemy].
  /// [reloadTime] Die Nachladedauer, bis ein neues Prjektil abgefeutert werden kann.
  factory Enemy.fromType(String type, String id, Vector2 position, Vector2 collisionBoxSize, Level level, double speed, int lifepoints, double viewRadius, Vector2 rotation, double projectileSpeed, double projectileScale, int reloadTime){
    switch (type) {
      case "fighter":
        return Fighter(id, position, collisionBoxSize, level, speed, lifepoints, viewRadius, rotation, projectileSpeed, projectileScale, reloadTime);
        break;
      case "hunter":
        return Hunter(id, position, collisionBoxSize, level, speed, lifepoints, viewRadius, rotation, projectileSpeed, projectileScale, reloadTime);
        break; 
      case "destroyer":
        return Destroyer(id, position, collisionBoxSize, level, speed, lifepoints, viewRadius, rotation, projectileSpeed, projectileScale, reloadTime);
        break;   
      default:
        return null;
    }
  }

  double get viewRadius => this._viewRadius;

  /// Liefert die aktuelle Zielposition. Diese Position
  /// wird z.B. in [Enemy] zur Berechnung der [preferedPosition] verwendet.
  Vector2 get randomTargetPos => this._randomTargetPos;

  /// Setzt die Zielposition.
  set randomTargetPos(Vector2 value) => this._randomTargetPos = value.clone();

  @override
  void actionOnCollide(LevelObject other) {
    if(other.id.contains("projectile")){
      Projectile projectile = other;
      if(!(projectile._owner.id.contains("enemy"))) decreaseLifepointsBy(1);
    }
  }

  @override
  void move({double dx, double dy, pxPerFrame}){
    super.move(pxPerFrame: pxPerFrame);
    List<LevelObject> list = List.from(level.getFilteredProjectiles(owner:"player"));
    list.add(level.playerCharacter);
    Vector2 offset = Vector2(0, 0);
    for (var item in list) {
      if(item._isActive && item != this){
        Vector2 correction = this.collisionCircle.resolveCollision(item.collisionCircle);
        if(correction != Vector2.zero()){
          offset += correction;
          this.actionOnCollide(item);
          item.actionOnCollide(this);
        }
      }
    } 
    position += offset.scaled(1.01);
    collisionCircle.position.setFrom(position);
  }

  @override
  void actionOnCollideWithWall(String wall){
     _randomTargetPos.setFrom(level.pickRandomPos(shouldNotOccur: _randomTargetPos));
  }

  /// Findet den bedrohlichsten Vektor aus [aheadList], der zu nah an [avoidableObject] liegt und gibt ihn zurueck.
  /// Dabei darf [avoidableObject] kein Projektil dieses Gegners sein.
  /// Ansonsten wird [null] zurueckgegeben, falls [avoidableObject] nicht nah genug an einem Vektor aus [aheadList] liegt. 
  /// [aheadList] Eine Liste aus Positionen, welche vor dem Gegner platziert sind.
  /// [avoidableObject] Das Objekt, welches auf [aheadList] ueberprueft wird.
  Vector2 _findMostThreateningAhead(List<Vector2> aheadList, LevelObject avoidableObject) {
    for (Vector2 ahead in aheadList) {
      if ((avoidableObject.position.distanceTo(ahead) < (avoidableObject.collisionCircle.radius + collisionCircle.radius))) {
        return ahead;
      } // In Reichweite des Objekt Radius + Spieler Radius.
    }
    return null;
  }

  /// Findet das bedrohlichste Objekt, welches kein eigenes Projektil ist, aus [aheadList] und gib es zurueck. Ansosnten wird null zurueckgegeben.
  /// [aheadList] Eine Liste aus Positionen, welche vor dem Gegner platziert sind.
  LevelObject _findMostThreateningObject(List<Vector2> aheadList);

  /// Gibt abhaenig vom [viewRadius] des Gegners einen [Vector2] aus, um Projektilen und dem Spieler ausweichen zu koennen.
  Vector2 _avoidCollision() {
    List<Vector2> aheadList = List(); // Die aheadList beschreibt pruefbare Positionen.
    Vector2 ahead;
    for (double i = 0.0; i <= 1; i += 0.1) {
      if (i == 0.0) ahead = position + velocity.normalized();
      else ahead = position + (velocity.normalized() * i * viewRadius);
      aheadList.add(ahead);
    }
    
    LevelObject mostThreatening = _findMostThreateningObject(aheadList);
    Vector2 avoidance = new Vector2.zero();
    if (mostThreatening != null) {
      
      Vector2 aheadP1 = Vector2(-velocity.y, velocity.x);
      Vector2 aheadP2 = Vector2(-velocity.y, velocity.x).scaled(-1);
      
      Vector2 targetToAhead = aheadList.first - mostThreatening.position;

      double dot1 = aheadP1.dot(targetToAhead);
      double dot2 = aheadP2.dot(targetToAhead);
      
      if(dot1 > 0) avoidance = aheadP1;
      else avoidance = aheadP2;

      avoidance.normalize();
    }
    return avoidance;
  }

  /// Fokussiert das [target] und bewegt sich in dessen Richtung.
  /// [target] Das [LevelObject], welches fokussiert werden soll.
  Vector2 targetLevelObject(LevelObject target) {
    Vector2 enemyToPlayer = target.position - position;
    if(enemyToPlayer.length <= viewRadius){
      shoot(target.position);
      return target.position;
    }else{
      return randomTargetPos;
    }
  }

  @override
  void updateTimer(){
    if(_reloadTimer.isRunning && _reloadTimer.elapsedMilliseconds >= reloadTime){
      _reloadTimer.stop();
      _reloadTimer.reset();
    }
  }
}