part of solarspace;

class Hunter extends Enemy{
  /// Die Kraft, welche als Skalar fuer die Staerke des Ausweichens genutzt wird. 
  final MAX_AVOID_FORCE = 12.0;
  /// Die Kraft, welche als Skalar fuer die Staerke des Verfolgens genutzt wird.
  final MAX_SEEK_FORCE = 1.0;

  /// Konstruktor.
  /// [id] Die ID soll folgender Form haben: <prefix>_<id> (nicht null).
  /// [position] Startposition des Mittelpunktes (nicht null).
  /// [collisionBoxSize] Größe der Hitbox, dabei ist x die Breite und y die Höhe (nicht null).
  /// [level] Levelinstanz, die dem [Hunter] zugewiesen werden soll (nicht null).
  /// [speed] Geschwindigkeit des [Hunter].
  /// [lifepoints] Anzahl an Leben.
  /// [viewRadius] Sichtweite des [Hunter].
  /// [rotation] Startrotation (nicht null).
  /// [projectileSpeed] Die Geschwindigkeit der Projektile des [Hunter].
  /// [projectileScale] Die Groesse der Projektile des [Hunter].
  /// [reloadTime] Die Nachladedauer, bis ein neues Prjektil abgefeutert werden kann.
  Hunter(String id, Vector2 position, Vector2 collisionBoxSize, Level level, double speed, int lifepoints, double viewRadius, Vector2 rotation, double projectileSpeed, double projectileScale, int reloadTime) : 
  super(id, position, collisionBoxSize, level, speed, lifepoints, viewRadius, rotation, projectileSpeed, projectileScale, reloadTime);

  @override
  LevelObject clone() {
    return Hunter(
      id, 
      Vector2.copy(position), 
      Vector2.copy(collisionCircle.size), 
      level, speed, lifepoints, viewRadius, 
      Vector2.copy(rotation),
      projectileSpeed, projectileScale, reloadTime);
  }

  @override
  void _updatePosition({double dx, double dy, double pxPerFrame}){
    Vector2 target = targetLevelObject(level.playerCharacter);
    velocity = (target - position).normalized().scaled(MAX_SEEK_FORCE);
    velocity += _avoidCollision().scaled(MAX_AVOID_FORCE);
    

    velocity.normalize();
    velocity.scale(pxPerFrame * speed);
    position += velocity;
    collisionCircle.position.setFrom(position);
    rotate(target);
  }

  @override
  LevelObject _findMostThreateningObject(List<Vector2> aheadList){
    List<LevelObject> avoidableObjects = level.getFilteredProjectiles(owner: "player"); // level.getblabla
    LevelObject mostThreatening;
    for (LevelObject avoidableObject in avoidableObjects) {
      bool isIntersection = _findMostThreateningAhead(aheadList, avoidableObject) == null ? false : true; // Schneiden sich der Radius von "avoidableObject" und einem Vektor aus "aheadList"?
      if ((isIntersection) && ((mostThreatening == null) || (this.position.distanceTo(avoidableObject.position) <= this.position.distanceTo(mostThreatening.position))))  {mostThreatening = avoidableObject;} // Finde das naehste Objekt.
    }
    return mostThreatening;
  }
}